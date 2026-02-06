import winston from 'winston';
import path from 'path';
import { config } from '../config/env';

// Define log levels
const levels = {
  error: 0,
  warn: 1,
  info: 2,
  http: 3,
  debug: 4,
};

// Define log colors
const colors = {
  error: 'red',
  warn: 'yellow',
  info: 'green',
  http: 'magenta',
  debug: 'blue',
};

// Tell winston about our colors
winston.addColors(colors);

// Define log format
const format = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  winston.format.errors({ stack: true }),
  winston.format.splat(),
  winston.format.json()
);

// Console format for development (colored and readable)
const consoleFormat = winston.format.combine(
  winston.format.colorize({ all: true }),
  winston.format.timestamp({ format: 'HH:mm:ss' }),
  winston.format.printf(
    (info) => {
      const { timestamp, level, message, ...meta } = info;
      
      // Format metadata if present
      let metaStr = '';
      if (Object.keys(meta).length > 0 && !meta.stack) {
        metaStr = '\n' + JSON.stringify(meta, null, 2);
      }
      
      // Include stack trace for errors
      if (meta.stack) {
        metaStr = '\n' + meta.stack;
      }
      
      return `${timestamp} [${level}]: ${message}${metaStr}`;
    }
  )
);

// Define which transports to use
const transports: winston.transport[] = [
  // Console transport (always enabled)
  new winston.transports.Console({
    format: config.nodeEnv === 'production' ? format : consoleFormat,
    level: config.nodeEnv === 'production' ? 'info' : 'debug',
  }),
];

// Add file transports in production or if LOG_TO_FILE is set
if (config.nodeEnv === 'production' || process.env.LOG_TO_FILE === 'true') {
  const logsDir = path.join(process.cwd(), 'logs');
  
  // Error log file
  transports.push(
    new winston.transports.File({
      filename: path.join(logsDir, 'error.log'),
      level: 'error',
      format,
      maxsize: 5242880, // 5MB
      maxFiles: 5,
    })
  );
  
  // Combined log file
  transports.push(
    new winston.transports.File({
      filename: path.join(logsDir, 'combined.log'),
      format,
      maxsize: 5242880, // 5MB
      maxFiles: 5,
    })
  );
  
  // HTTP requests log file
  transports.push(
    new winston.transports.File({
      filename: path.join(logsDir, 'http.log'),
      level: 'http',
      format,
      maxsize: 5242880, // 5MB
      maxFiles: 5,
    })
  );
  
}

// Create the main API logger
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || (config.nodeEnv === 'production' ? 'info' : 'debug'),
  levels,
  format,
  transports,
  // Don't exit on handled exceptions
  exitOnError: false,
});

// Create separate UI logger (only writes to ui.log, not console or other files)
let uiLogger: winston.Logger | null = null;
if (config.nodeEnv === 'production' || process.env.LOG_TO_FILE === 'true') {
  const logsDir = path.join(process.cwd(), 'logs');
  uiLogger = winston.createLogger({
    level: 'debug',
    levels,
    format,
    transports: [
      new winston.transports.File({
        filename: path.join(logsDir, 'ui.log'),
        format,
        maxsize: 5242880, // 5MB
        maxFiles: 5,
      }),
    ],
    exitOnError: false,
  });
} else {
  // In dev, also log to console
  uiLogger = winston.createLogger({
    level: 'debug',
    levels,
    format: consoleFormat,
    transports: [
      new winston.transports.Console({
        format: consoleFormat,
      }),
    ],
    exitOnError: false,
  });
}

// Create a stream object for Morgan HTTP logger
export const morganStream = {
  write: (message: string) => {
    logger.http(message.trim());
  },
};

// Helper methods for structured logging
export const logRequest = (req: any, res: any, responseTime?: number) => {
  const { method, originalUrl, ip } = req;
  const { statusCode } = res;
  const userId = req.user?.id || 'anonymous';
  
  const logData: any = {
    method,
    url: originalUrl,
    statusCode,
    ip,
    userId,
  };
  
  if (responseTime) {
    logData.responseTime = `${responseTime}ms`;
  }
  
  // Log level based on status code
  if (statusCode >= 500) {
    logger.error('Request failed', logData);
  } else if (statusCode >= 400) {
    logger.warn('Request error', logData);
  } else {
    logger.http('Request', logData);
  }
};

export const logError = (error: Error, context?: Record<string, any>) => {
  const { level, ...restContext } = context || {};
  const logLevel = level === 'warn' ? 'warn' : 'error';
  
  logger[logLevel](error.message, {
    error: error.message,
    stack: error.stack,
    ...restContext,
  });
};

export const logInfo = (message: string, meta?: Record<string, any>) => {
  logger.info(message, meta);
};

export const logWarn = (message: string, meta?: Record<string, any>) => {
  logger.warn(message, meta);
};

export const logDebug = (message: string, meta?: Record<string, any>) => {
  logger.debug(message, meta);
};

// UI Logger helpers (separate from API logs)
export const logUiInfo = (message: string, meta?: Record<string, any>) => {
  if (uiLogger) {
    uiLogger.info(message, { source: 'ui', ...meta });
  }
};

export const logUiError = (error: Error | string, meta?: Record<string, any>) => {
  if (uiLogger) {
    const errorMessage = error instanceof Error ? error.message : error;
    const errorStack = error instanceof Error ? error.stack : undefined;
    uiLogger.error(errorMessage, { source: 'ui', error: errorMessage, stack: errorStack, ...meta });
  }
};

export const logUiWarn = (message: string, meta?: Record<string, any>) => {
  if (uiLogger) {
    uiLogger.warn(message, { source: 'ui', ...meta });
  }
};

export const logUiDebug = (message: string, meta?: Record<string, any>) => {
  if (uiLogger) {
    uiLogger.debug(message, { source: 'ui', ...meta });
  }
};

export { uiLogger };
export default logger;
