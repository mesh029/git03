import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { createServer } from 'http';
import { config } from './config/env';
import pool from './config/database';
import redisClient from './config/redis';
import { errorHandler } from './middleware/errorHandler';
import { requestLogger } from './middleware/requestLogger';
import { webSocketService } from './services/websocketService';
import logger, { logInfo, logError, logWarn } from './utils/logger';

const app = express();
const httpServer = createServer(app);

// Middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'", "'unsafe-eval'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"],
    },
  },
}));
app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (like mobile apps or curl)
    if (!origin) return callback(null, true);
    
    const allowedOrigins = Array.isArray(config.cors.origin) 
      ? config.cors.origin 
      : [config.cors.origin];
    
    if (allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      // In development, allow all origins for easier debugging
      if (config.nodeEnv === 'development') {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging middleware (must be after body parsers)
app.use(requestLogger);

// Health check endpoint
app.get('/health', async (_req, res) => {
  try {
    // Check database connection
    await pool.query('SELECT 1');
    
    // Check Redis connection
    await redisClient.ping();
    
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
import authRoutes from './routes/authRoutes';
import orderRoutes from './routes/orderRoutes';
import locationRoutes from './routes/locationRoutes';
import propertyRoutes from './routes/propertyRoutes';
import adminRoutes from './routes/adminRoutes';
import subscriptionRoutes from './routes/subscriptionRoutes';
import messageRoutes from './routes/messageRoutes';
import serviceLocationRoutes from './routes/serviceLocationRoutes';
import logRoutes from './routes/logRoutes';

app.get('/v1', (_req, res) => {
  res.json({
    message: 'JuaX API v1',
    version: '1.0.0-MVP',
  });
});

app.use('/v1/auth', authRoutes);
app.use('/v1/orders', orderRoutes);
app.use('/v1/locations', locationRoutes);
app.use('/v1/properties', propertyRoutes);
app.use('/v1/admin', adminRoutes);
app.use('/v1/subscriptions', subscriptionRoutes);
app.use('/v1/messages', messageRoutes);
app.use('/v1/service-locations', serviceLocationRoutes);
app.use('/v1/logs', logRoutes);

// Error handling middleware
app.use(errorHandler);

// 404 handler
app.use((_req, res) => {
  res.status(404).json({
    success: false,
    error: {
      code: 'NOT_FOUND',
      message: 'Resource not found',
    },
  });
});

// Initialize WebSocket server
webSocketService.initialize(httpServer);

// Start server (only if not in test environment and not imported as module)
const startServer = async () => {
  try {
    logInfo('🚀 Starting JuaX API Server...', {
      environment: config.nodeEnv,
      port: config.port,
    });

    // Test database connection
    await pool.query('SELECT NOW()');
    logInfo('✅ Database connected', {
      database: 'PostgreSQL',
    });
    
    // Test Redis connection
    await redisClient.ping();
    logInfo('✅ Redis connected', {
      cache: 'Redis',
    });
    
    httpServer.listen(config.port, () => {
      logInfo('🎉 Server started successfully', {
        port: config.port,
        environment: config.nodeEnv,
        healthCheck: `http://localhost:${config.port}/health`,
        apiBase: `http://localhost:${config.port}/v1`,
        websocket: '/socket.io',
      });
      
      // Log startup banner
      logger.info('');
      logger.info('═══════════════════════════════════════════════════════════');
      logger.info('  🚀 JuaX API Server');
      logger.info('═══════════════════════════════════════════════════════════');
      logger.info(`  📍 Port: ${config.port}`);
      logger.info(`  🌍 Environment: ${config.nodeEnv}`);
      logger.info(`  🔗 Health: http://localhost:${config.port}/health`);
      logger.info(`  📡 API: http://localhost:${config.port}/v1`);
      logger.info(`  📊 Logs Viewer: http://localhost:${config.port}/v1/logs/viewer`);
      logger.info(`  🔌 WebSocket: /socket.io`);
      logger.info('═══════════════════════════════════════════════════════════');
      logger.info('');
    });
  } catch (error) {
    logError(error as Error, {
      context: 'server_startup',
    });
    process.exit(1);
  }
};

// Only start server if this file is run directly (not imported)
if (require.main === module && process.env.NODE_ENV !== 'test') {
  startServer();
}

// Graceful shutdown
const gracefulShutdown = async (signal: string) => {
  logWarn(`${signal} signal received: shutting down gracefully...`);
  
  httpServer.close(() => {
    logInfo('HTTP server closed');
  });
  
  try {
    await pool.end();
    logInfo('Database connection closed');
  } catch (error) {
    logError(error as Error, { context: 'database_shutdown' });
  }
  
  try {
    await redisClient.quit();
    logInfo('Redis connection closed');
  } catch (error) {
    logError(error as Error, { context: 'redis_shutdown' });
  }
  
  logInfo('Shutdown complete');
  process.exit(0);
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  logError(error, { context: 'uncaught_exception' });
  process.exit(1);
});

// Handle unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  logError(new Error(`Unhandled Rejection: ${reason}`), {
    context: 'unhandled_rejection',
    promise: promise.toString(),
  });
});

export default app;
export { httpServer };
