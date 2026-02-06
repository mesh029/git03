# 📝 Logging System Documentation

## Overview

The JuaX API uses **Winston** for comprehensive logging with colored console output in development and file logging in production.

## Features

✅ **Colored Console Output** - Easy to read logs in development  
✅ **Request Logging** - All HTTP requests logged with method, URL, status, response time  
✅ **Error Tracking** - Detailed error logs with stack traces  
✅ **File Logging** - Automatic file rotation in production  
✅ **Structured Logging** - JSON format for easy parsing  
✅ **Log Levels** - Debug, Info, HTTP, Warn, Error  
✅ **Browser Log Viewer** - View logs in real-time via web interface  

## Log Levels

- **DEBUG** - Detailed information for debugging
- **INFO** - General informational messages
- **HTTP** - HTTP request/response logging
- **WARN** - Warning messages (non-critical issues)
- **ERROR** - Error messages (critical issues)

## Configuration

### Environment Variables

```bash
# Set log level (default: 'debug' in dev, 'info' in production)
LOG_LEVEL=debug

# Enable file logging (default: enabled in production)
LOG_TO_FILE=true
```

### Log Files Location

Logs are stored in the `logs/` directory:
- `logs/error.log` - Error level logs only
- `logs/http.log` - HTTP request logs
- `logs/combined.log` - All logs combined

## Usage Examples

### In Code

```typescript
import logger, { logInfo, logError, logWarn, logDebug } from './utils/logger';

// Info log
logInfo('User logged in', { userId: '123', email: 'user@example.com' });

// Error log
try {
  // some code
} catch (error) {
  logError(error as Error, { context: 'user_login', userId: '123' });
}

// Warning log
logWarn('Rate limit approaching', { userId: '123', requests: 95 });

// Debug log
logDebug('Processing request', { method: 'POST', url: '/v1/orders' });
```

### Request Logging

Request logging is automatic via middleware. Each request logs:
- HTTP method
- URL
- Status code
- Response time
- User ID (if authenticated)
- IP address

Example output:
```
14:23:45 [http]: Request {
  "method": "POST",
  "url": "/v1/auth/login",
  "statusCode": 200,
  "responseTime": "45ms",
  "userId": "anonymous",
  "ip": "::1"
}
```

## Console Output Format

### Development Mode
```
14:23:45 [info]: 🚀 Starting JuaX API Server...
14:23:45 [info]: ✅ Database connected
14:23:45 [info]: ✅ Redis connected
14:23:46 [info]: 🎉 Server started successfully
```

### Production Mode
JSON format for easy parsing by log aggregation tools:
```json
{
  "timestamp": "2024-01-15 14:23:45",
  "level": "info",
  "message": "Server started successfully",
  "port": 3000,
  "environment": "production"
}
```

## Startup Banner

When the server starts, you'll see:
```
═══════════════════════════════════════════════════════════
  🚀 JuaX API Server
═══════════════════════════════════════════════════════════
  📍 Port: 3000
  🌍 Environment: development
  🔗 Health: http://localhost:3000/health
  📡 API: http://localhost:3000/v1
  🔌 WebSocket: /socket.io
═══════════════════════════════════════════════════════════
```

## Error Logging

Errors are automatically logged with:
- Error message
- Stack trace
- Request context (URL, method, user, IP)
- Request body/query/params (for debugging)

Example error log:
```
14:23:45 [error]: Validation failed {
  "error": "Invalid email format",
  "stack": "Error: Invalid email format\n    at ...",
  "url": "/v1/auth/register",
  "method": "POST",
  "userId": "anonymous",
  "ip": "::1",
  "body": { "email": "invalid" }
}
```

## Log Rotation

Log files automatically rotate when they reach 5MB:
- Maximum 5 files per log type
- Old files are automatically deleted
- Prevents disk space issues

## Best Practices

1. **Use appropriate log levels**:
   - `debug` - Development debugging
   - `info` - Important events (server start, user actions)
   - `warn` - Non-critical issues (rate limits, validation errors)
   - `error` - Critical issues (exceptions, failures)

2. **Include context**:
   ```typescript
   logInfo('Order created', {
     orderId: order.id,
     userId: user.id,
     amount: order.total,
   });
   ```

3. **Don't log sensitive data**:
   - Never log passwords, tokens, or credit card numbers
   - Sanitize user input in logs

4. **Use structured logging**:
   - Always pass metadata as objects
   - Makes logs easier to search and parse

## Browser Log Viewer

View logs directly in your browser! 🎉

### Access the Log Viewer

1. **Start your server**:
   ```bash
   npm run dev
   ```

2. **Open in browser**:
   ```
   http://localhost:3000/v1/logs/viewer
   ```

### Features

- 📊 **Real-time log viewing** - See logs as they happen
- 🔍 **Filter by level** - Filter by error, warn, info, http, or debug
- 🔄 **Auto-refresh** - Automatically refresh every 5 seconds
- 📈 **Statistics** - See counts of each log level
- 🎨 **Color-coded** - Easy to spot errors and warnings
- 📝 **Structured display** - View metadata and stack traces

### API Endpoints

- `GET /v1/logs/viewer` - Log viewer HTML page
- `GET /v1/logs/recent?limit=100&level=error` - Get recent logs (JSON)
- `GET /v1/logs/files` - List available log files
- `GET /v1/logs/files/:filename` - Get specific log file contents

### Example API Usage

```bash
# Get last 50 error logs
curl http://localhost:3000/v1/logs/recent?limit=50&level=error

# Get last 100 logs of any level
curl http://localhost:3000/v1/logs/recent?limit=100

# List all log files
curl http://localhost:3000/v1/logs/files
```

## Monitoring

In production, you can:
- Use log aggregation tools (ELK, Datadog, etc.)
- Set up alerts on error logs
- Monitor request patterns via HTTP logs
- Track performance via response times
- Use the browser log viewer for quick debugging

## Troubleshooting

### Logs not appearing
- Check `LOG_LEVEL` environment variable
- Verify `logs/` directory exists and is writable
- Check file permissions

### Too many logs
- Increase log level: `LOG_LEVEL=info` or `LOG_LEVEL=warn`
- Disable file logging: `LOG_TO_FILE=false`

### Log files too large
- Logs auto-rotate at 5MB
- Old logs are automatically deleted
- Check `logs/` directory periodically
