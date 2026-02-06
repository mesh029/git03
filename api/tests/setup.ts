import { Pool } from 'pg';
import { createClient } from 'redis';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { createServer, Server as HttpServer } from 'http';

// Test database configuration - set before any other imports
const TEST_DATABASE_URL = process.env.DATABASE_URL || 'postgresql://juax:juax_dev@localhost:5432/juax_test';
const TEST_REDIS_URL = process.env.REDIS_URL || 'redis://localhost:6379/1';

let testPool: Pool;
let testRedis: ReturnType<typeof createClient>;
let testApp: express.Application;
let testHttpServer: HttpServer;

/**
 * Initialize test database connection
 */
export async function setupTestDatabase(): Promise<Pool> {
  if (!testPool) {
    testPool = new Pool({
      connectionString: TEST_DATABASE_URL,
    });
  }
  return testPool;
}

/**
 * Initialize test Redis connection
 */
export async function setupTestRedis() {
  if (!testRedis) {
    testRedis = createClient({
      url: TEST_REDIS_URL,
    });
    await testRedis.connect();
  }
  return testRedis;
}

/**
 * Clean up test database (truncate all tables)
 */
export async function cleanupTestDatabase(): Promise<void> {
  if (testPool) {
    try {
      // Delete in order to respect foreign key constraints
      // Use IF EXISTS to handle missing tables gracefully
      const tables = [
        'messages',
        'conversation_participants',
        'conversations',
        'subscription_features',
        'subscriptions',
        'order_status_history',
        'order_tracking',
        'property_bookings',
        'orders',
        'properties',
        'users',
      ];

      for (const table of tables) {
        try {
          await testPool.query(`DELETE FROM ${table}`);
        } catch (error: any) {
          // Ignore "relation does not exist" errors
          if (error.code !== '42P01') {
            throw error;
          }
        }
      }
    } catch (error) {
      console.error('Error cleaning up test database:', error);
      throw error;
    }
  }
}

/**
 * Clean up test Redis (flush database)
 */
export async function cleanupTestRedis(): Promise<void> {
  if (testRedis) {
    await testRedis.flushDb();
  }
}

/**
 * Close all test connections
 */
export async function closeTestConnections(): Promise<void> {
  const closePromises: Promise<void>[] = [];
  
  if (testHttpServer) {
    closePromises.push(
      new Promise<void>((resolve) => {
        testHttpServer.close(() => resolve());
      })
    );
  }
  
  if (testPool) {
    closePromises.push(
      testPool.end().catch((error) => {
        console.error('Error closing test database pool:', error);
      })
    );
  }
  
  if (testRedis) {
    closePromises.push(
      testRedis.quit().catch((error) => {
        console.error('Error closing test Redis connection:', error);
      })
    );
  }
  
  await Promise.all(closePromises);
}

/**
 * Initialize test app (call this in beforeAll)
 */
export async function initializeTestApp(): Promise<void> {
  if (!testApp) {
    // Ensure database and Redis are initialized
    await setupTestDatabase();
    await setupTestRedis();

    // Import routes after env vars are set
    const { errorHandler } = await import('../src/middleware/errorHandler');
    const authRoutes = (await import('../src/routes/authRoutes')).default;
    const orderRoutes = (await import('../src/routes/orderRoutes')).default;
    const locationRoutes = (await import('../src/routes/locationRoutes')).default;
    const propertyRoutes = (await import('../src/routes/propertyRoutes')).default;
    const adminRoutes = (await import('../src/routes/adminRoutes')).default;
    const subscriptionRoutes = (await import('../src/routes/subscriptionRoutes')).default;
    const messageRoutes = (await import('../src/routes/messageRoutes')).default;

    testApp = express();

    // Middleware
    testApp.use(helmet());
    testApp.use(cors({
      origin: '*',
      credentials: true,
    }));
    testApp.use(express.json());
    testApp.use(express.urlencoded({ extended: true }));

    // Health check endpoint
    testApp.get('/health', async (_req, res) => {
      try {
        await testPool!.query('SELECT 1');
        await testRedis!.ping();
        res.status(200).json({
          status: 'healthy',
          timestamp: new Date().toISOString(),
          services: {
            database: 'connected',
            redis: 'connected',
          },
        });
      } catch (error) {
        res.status(503).json({
          status: 'unhealthy',
          timestamp: new Date().toISOString(),
          error: error instanceof Error ? error.message : 'Unknown error',
        });
      }
    });

    // API routes
    testApp.get('/v1', (_req, res) => {
      res.json({
        message: 'JuaX API v1',
        version: '1.0.0-MVP',
      });
    });

    testApp.use('/v1/auth', authRoutes);
    testApp.use('/v1/orders', orderRoutes);
    testApp.use('/v1/locations', locationRoutes);
    testApp.use('/v1/properties', propertyRoutes);
    testApp.use('/v1/admin', adminRoutes);
    testApp.use('/v1/subscriptions', subscriptionRoutes);
    testApp.use('/v1/messages', messageRoutes);

    // Error handling middleware
    testApp.use(errorHandler);

    // 404 handler
    testApp.use((_req, res) => {
      res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'Resource not found',
        },
      });
    });

    // Create HTTP server for WebSocket support
    testHttpServer = createServer(testApp);

    // Initialize WebSocket service
    const { webSocketService } = await import('../src/services/websocketService');
    webSocketService.initialize(testHttpServer);

    // Start server on random port for tests
    await new Promise<void>((resolve) => {
      testHttpServer.listen(0, () => {
        resolve();
      });
    });
  }
}

/**
 * Get test app instance (must call initializeTestApp first)
 */
export function getTestApp(): express.Application {
  if (!testApp) {
    throw new Error('Test app not initialized. Call initializeTestApp() in beforeAll hook.');
  }
  return testApp;
}

/**
 * Get test HTTP server instance (must call initializeTestApp first)
 */
export function getTestHttpServer(): HttpServer {
  if (!testHttpServer) {
    throw new Error('Test HTTP server not initialized. Call initializeTestApp() in beforeAll hook.');
  }
  return testHttpServer;
}

/**
 * Get test server port
 */
export function getTestServerPort(): number {
  if (!testHttpServer) {
    throw new Error('Test HTTP server not initialized.');
  }
  const address = testHttpServer.address();
  if (typeof address === 'string' || !address) {
    throw new Error('Server address not available');
  }
  return address.port;
}
