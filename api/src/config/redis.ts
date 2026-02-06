import { createClient } from 'redis';
import dotenv from 'dotenv';
import { logError, logInfo, logWarn } from '../utils/logger';

dotenv.config();

const redisClient = createClient({
  url: process.env.REDIS_URL || 'redis://localhost:6379',
  socket: {
    reconnectStrategy: (retries) => {
      if (retries > 10) {
        logWarn('Redis reconnection attempts exceeded, stopping retries');
        return new Error('Redis connection failed after 10 retries');
      }
      // Exponential backoff: 50ms, 100ms, 200ms, 400ms, 800ms, etc. (max 3s)
      const delay = Math.min(50 * Math.pow(2, retries), 3000);
      return delay;
    },
    connectTimeout: 5000, // 5 second connection timeout
  },
});

// Only log errors after initial connection attempt
let hasConnected = false;
let connectionAttempts = 0;

redisClient.on('error', (err) => {
  // Only log errors if we've already connected (connection lost) or after multiple failed attempts
  // Initial connection timeouts are expected and will auto-retry
  const errorMessage = err instanceof Error ? err.message : String(err);
  if (hasConnected) {
    // Connection was established but then lost - log it
    logError(err as Error, { context: 'redis_client' });
  } else if (errorMessage.includes('timeout') && connectionAttempts <= 1) {
    // Initial timeout is expected - Redis will auto-reconnect, don't log as error
    // Just log as debug/info level if needed
  } else if (connectionAttempts > 3) {
    // Multiple failed attempts - log as warning
    logWarn(`Redis connection attempt ${connectionAttempts} failed: ${errorMessage}`, {
      context: 'redis_client',
    });
  }
});

redisClient.on('connect', () => {
  hasConnected = true;
  logInfo('Redis client connected');
});

redisClient.on('ready', () => {
  logInfo('Redis client ready');
});

redisClient.on('reconnecting', () => {
  logWarn('Redis client reconnecting...');
});

// Connect to Redis with retry logic
const connectRedis = async () => {
  if (redisClient.isOpen) {
    return;
  }

  try {
    connectionAttempts++;
    await redisClient.connect();
  } catch (err) {
    // Initial connection failures are expected if Redis isn't ready yet
    if (connectionAttempts <= 3) {
      // Silently retry - Redis will auto-reconnect
      return;
    }
    logError(err as Error, { context: 'redis_connection' });
  }
};

// Attempt initial connection
connectRedis();

export default redisClient;
