# 🚀 Starting the API Server with Logging

## Quick Start

```bash
cd api
npm run dev
```

## What You'll See

When the server starts successfully, you'll see:

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

14:23:45 [info]: 🚀 Starting JuaX API Server...
14:23:45 [info]: ✅ Database connected
14:23:45 [info]: ✅ Redis connected
14:23:46 [info]: 🎉 Server started successfully
```

## Request Logs

Every HTTP request will be logged:

```
14:23:50 [http]: Request {
  "method": "POST",
  "url": "/v1/auth/login",
  "statusCode": 200,
  "responseTime": "45ms",
  "userId": "anonymous",
  "ip": "::1"
}
```

## Error Logs

Errors are logged with full context:

```
14:23:50 [error]: Invalid email or password {
  "error": "Invalid email or password",
  "stack": "...",
  "url": "/v1/auth/login",
  "method": "POST"
}
```

## Access the API

- **Health Check**: http://localhost:3000/health
- **API Base**: http://localhost:3000/v1
- **WebSocket**: ws://localhost:3000/socket.io

## View Logs

The server logs directly to the console. To see logs in real-time:

```bash
# In the terminal where you ran npm run dev
# Logs will appear automatically
```

## Troubleshooting

If the server doesn't start:

1. **Check for compilation errors**:
   ```bash
   npm run build
   ```

2. **Check if port 3000 is in use**:
   ```bash
   lsof -ti:3000
   ```

3. **Kill existing processes**:
   ```bash
   pkill -f nodemon
   ```

4. **Check database connection**:
   ```bash
   docker-compose ps
   ```

## Log Levels

- `debug` - Detailed debugging info (development)
- `info` - General information
- `http` - HTTP requests
- `warn` - Warnings
- `error` - Errors

Set log level in `.env`:
```bash
LOG_LEVEL=debug
```
