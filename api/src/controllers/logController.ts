import { Request, Response } from 'express';
import fs from 'fs/promises';
import path from 'path';
import { NotFoundError } from '../utils/errors';

export class LogController {
  /**
   * Get list of available log files
   */
  async getLogFiles(_req: Request, res: Response): Promise<void> {
    try {
      const logsDir = path.join(process.cwd(), 'logs');
      
      // Check if logs directory exists
      try {
        await fs.access(logsDir);
      } catch {
        res.json({
          success: true,
          data: {
            files: [],
            message: 'Logs directory does not exist. Enable file logging with LOG_TO_FILE=true',
          },
        });
        return;
      }

      const files = await fs.readdir(logsDir);
      const logFiles = files
        .filter((file) => file.endsWith('.log'))
        .map((file) => ({
          name: file,
          path: `/logs/${file}`,
        }));

      res.json({
        success: true,
        data: {
          files: logFiles,
        },
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Failed to read log files',
      });
    }
  }

  /**
   * Get log file contents
   */
  async getLogFile(req: Request, res: Response): Promise<void> {
    try {
      const { filename } = req.params;
      
      // Security: prevent directory traversal
      if (filename.includes('..') || filename.includes('/') || filename.includes('\\')) {
        throw new NotFoundError('Log file');
      }

      const logsDir = path.join(process.cwd(), 'logs');
      const filePath = path.join(logsDir, filename);

      // Check if file exists
      try {
        await fs.access(filePath);
      } catch {
        throw new NotFoundError('Log file');
      }

      // Read file
      const content = await fs.readFile(filePath, 'utf-8');
      
      // Parse JSON lines (each line is a JSON object)
      const lines = content
        .split('\n')
        .filter((line) => line.trim())
        .map((line) => {
          try {
            return JSON.parse(line);
          } catch {
            // If not JSON, return as plain text
            return { raw: line };
          }
        });

      res.json({
        success: true,
        data: {
          filename,
          lines: lines.slice(-1000), // Last 1000 lines
          totalLines: lines.length,
        },
      });
    } catch (error) {
      if (error instanceof NotFoundError) {
        res.status(404).json({
          success: false,
          error: 'Log file not found',
        });
        return;
      }

      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Failed to read log file',
      });
    }
  }

  /**
   * Get recent UI logs (last N lines from ui.log)
   */
  async getRecentUiLogs(req: Request, res: Response): Promise<void> {
    try {
      const { limit = '100', level = 'all' } = req.query;
      const logLimit = parseInt(limit as string, 10);
      const logLevel = level as string;

      const logFilePath = path.join(process.cwd(), 'logs', 'ui.log');
      
      try {
        await fs.access(logFilePath);
      } catch {
        res.status(404).json({
          success: false,
          error: {
            code: 'LOG_FILE_NOT_FOUND',
            message: 'UI log file not found. Ensure LOG_TO_FILE is true in .env',
          },
        });
        return;
      }

      const fileContent = await fs.readFile(logFilePath, 'utf-8');
      const lines = fileContent.split('\n').filter(Boolean);

      let logs = lines
        .map((line) => {
          try {
            return JSON.parse(line);
          } catch {
            return { level: 'info', message: line, timestamp: new Date().toISOString() };
          }
        })
        .filter((log) => logLevel === 'all' || log.level === logLevel)
        .slice(-logLimit);

      res.status(200).json({
        success: true,
        data: {
          logs,
          count: logs.length,
          level: logLevel,
          source: 'ui',
        },
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Failed to read UI logs',
      });
    }
  }

  /**
   * Receive UI log from Flutter app
   */
  async receiveUiLog(req: Request, res: Response): Promise<void> {
    try {
      const { level, message, data, tag, error, stackTrace } = req.body;

      if (!message) {
        res.status(400).json({
          success: false,
          error: { code: 'VALIDATION_ERROR', message: 'Message is required' },
        });
        return;
      }

      // Import UI logger dynamically to avoid circular dependency
      const { logUiInfo, logUiError, logUiWarn, logUiDebug } = await import('../utils/logger');

      const logData: Record<string, unknown> = {
        tag: tag || 'APP',
        ...(data || {}),
      };

      if (error) logData.error = error;
      if (stackTrace) logData.stackTrace = stackTrace;

      // Log to UI log file using Winston UI logger
      switch (level?.toLowerCase()) {
        case 'error':
          logUiError(new Error(message), logData);
          break;
        case 'warning':
        case 'warn':
          logUiWarn(message, logData);
          break;
        case 'debug':
          logUiDebug(message, logData);
          break;
        default:
          logUiInfo(message, logData);
      }

      res.status(200).json({
        success: true,
        message: 'Log received',
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Failed to process log',
      });
    }
  }

  /**
   * Get recent logs (last N lines from combined.log) - API logs only
   */
  async getRecentLogs(req: Request, res: Response): Promise<void> {
    try {
      const limit = parseInt(req.query.limit as string) || 100;
      const level = req.query.level as string; // Optional filter by level

      const logsDir = path.join(process.cwd(), 'logs');
      const filePath = path.join(logsDir, 'combined.log');

      // Check if file exists
      try {
        await fs.access(filePath);
      } catch {
        res.json({
          success: true,
          data: {
            logs: [],
            message: 'No logs available. Enable file logging with LOG_TO_FILE=true',
          },
        });
        return;
      }

      // Read file
      const content = await fs.readFile(filePath, 'utf-8');
      
      // Parse JSON lines
      let lines = content
        .split('\n')
        .filter((line) => line.trim())
        .map((line) => {
          try {
            return JSON.parse(line);
          } catch {
            return null;
          }
        })
        .filter((line) => line !== null);

      // Filter by level if specified
      if (level) {
        lines = lines.filter((log: any) => log.level === level);
      }

      // Get last N lines
      const recentLogs = lines.slice(-limit);

      res.json({
        success: true,
        data: {
          logs: recentLogs,
          count: recentLogs.length,
          level: level || 'all',
        },
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error instanceof Error ? error.message : 'Failed to read logs',
      });
    }
  }

  /**
   * Serve log viewer HTML page
   */
  getLogViewer(_req: Request, res: Response): void {
    const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>JuaX API Logs Viewer</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    
    body {
      font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
      background: #1e1e1e;
      color: #d4d4d4;
      padding: 20px;
    }
    
    .container {
      max-width: 1400px;
      margin: 0 auto;
    }
    
    header {
      background: #252526;
      padding: 20px;
      border-radius: 8px;
      margin-bottom: 20px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      flex-wrap: wrap;
      gap: 15px;
    }
    
    h1 {
      color: #4ec9b0;
      font-size: 24px;
    }
    
    .controls {
      display: flex;
      gap: 10px;
      flex-wrap: wrap;
    }
    
    select, button {
      padding: 8px 16px;
      background: #3c3c3c;
      color: #d4d4d4;
      border: 1px solid #555;
      border-radius: 4px;
      cursor: pointer;
      font-family: inherit;
      font-size: 14px;
    }
    
    select:hover, button:hover {
      background: #464647;
    }
    
    button {
      background: #0e639c;
      border-color: #0e639c;
    }
    
    button:hover {
      background: #1177bb;
    }
    
    .auto-refresh {
      display: flex;
      align-items: center;
      gap: 8px;
    }
    
    input[type="checkbox"] {
      width: 18px;
      height: 18px;
      cursor: pointer;
    }
    
    .logs-container {
      background: #252526;
      border-radius: 8px;
      padding: 20px;
      max-height: 70vh;
      overflow-y: auto;
    }
    
    .log-entry {
      padding: 8px 12px;
      margin-bottom: 4px;
      border-left: 3px solid transparent;
      border-radius: 4px;
      font-size: 13px;
      line-height: 1.5;
      word-wrap: break-word;
    }
    
    .log-entry:hover {
      background: #2a2d2e;
    }
    
    .log-entry.error {
      border-left-color: #f48771;
      background: rgba(244, 135, 113, 0.1);
    }
    
    .log-entry.warn {
      border-left-color: #dcdcaa;
      background: rgba(220, 220, 170, 0.1);
    }
    
    .log-entry.info {
      border-left-color: #4ec9b0;
      background: rgba(78, 201, 176, 0.1);
    }
    
    .log-entry.http {
      border-left-color: #c586c0;
      background: rgba(197, 134, 192, 0.1);
    }
    
    .log-entry.debug {
      border-left-color: #569cd6;
      background: rgba(86, 156, 214, 0.1);
    }
    
    .log-timestamp {
      color: #858585;
      margin-right: 10px;
    }
    
    .log-level {
      font-weight: bold;
      margin-right: 10px;
      text-transform: uppercase;
    }
    
    .log-level.error { color: #f48771; }
    .log-level.warn { color: #dcdcaa; }
    .log-level.info { color: #4ec9b0; }
    .log-level.http { color: #c586c0; }
    .log-level.debug { color: #569cd6; }
    
    .log-message {
      color: #d4d4d4;
    }
    
    .log-meta {
      margin-top: 4px;
      padding-left: 20px;
      color: #858585;
      font-size: 12px;
    }
    
    .status {
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 12px;
      font-weight: bold;
    }
    
    .status.loading {
      background: #0e639c;
      color: white;
    }
    
    .status.error {
      background: #f48771;
      color: white;
    }
    
    .empty-state {
      text-align: center;
      padding: 40px;
      color: #858585;
    }
    
    .stats {
      display: flex;
      gap: 20px;
      margin-bottom: 20px;
      flex-wrap: wrap;
    }
    
    .stat-card {
      background: #252526;
      padding: 15px 20px;
      border-radius: 8px;
      flex: 1;
      min-width: 150px;
    }
    
    .stat-label {
      color: #858585;
      font-size: 12px;
      margin-bottom: 5px;
    }
    
    .stat-value {
      color: #4ec9b0;
      font-size: 24px;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <h1>📊 JuaX API Logs Viewer</h1>
      <div class="controls">
        <select id="levelFilter">
          <option value="">All Levels</option>
          <option value="error">Error</option>
          <option value="warn">Warning</option>
          <option value="info">Info</option>
          <option value="http">HTTP</option>
          <option value="debug">Debug</option>
        </select>
        <select id="limitSelect">
          <option value="50">Last 50</option>
          <option value="100" selected>Last 100</option>
          <option value="200">Last 200</option>
          <option value="500">Last 500</option>
          <option value="1000">Last 1000</option>
        </select>
        <button onclick="loadLogs()">Refresh</button>
        <div class="auto-refresh">
          <input type="checkbox" id="autoRefresh" onchange="toggleAutoRefresh()">
          <label for="autoRefresh">Auto-refresh (5s)</label>
        </div>
      </div>
    </header>
    
    <div class="stats" id="stats"></div>
    
    <div class="logs-container" id="logsContainer">
      <div class="empty-state">Loading logs...</div>
    </div>
  </div>

  <script>
    let autoRefreshInterval = null;
    
    function formatTimestamp(timestamp) {
      if (!timestamp) return '';
      try {
        // Handle both ISO format and custom format "YYYY-MM-DD HH:mm:ss"
        let date;
        if (timestamp.includes('T')) {
          date = new Date(timestamp);
        } else {
          // Handle "YYYY-MM-DD HH:mm:ss" format
          date = new Date(timestamp.replace(' ', 'T'));
        }
        if (isNaN(date.getTime())) {
          return timestamp; // Return original if parsing fails
        }
        return date.toLocaleTimeString('en-US', { 
          hour12: false,
          hour: '2-digit',
          minute: '2-digit',
          second: '2-digit'
        });
      } catch (e) {
        return timestamp; // Return original on error
      }
    }
    
    function formatLogEntry(log) {
      if (log.raw) {
        return \`<div class="log-entry">\${log.raw}</div>\`;
      }
      
      const level = log.level || 'info';
      const timestamp = formatTimestamp(log.timestamp);
      const message = log.message || '';
      
      // Format metadata
      const meta = { ...log };
      delete meta.timestamp;
      delete meta.level;
      delete meta.message;
      delete meta.stack;
      
      let metaHtml = '';
      if (Object.keys(meta).length > 0) {
        metaHtml = \`<div class="log-meta">\${JSON.stringify(meta, null, 2)}</div>\`;
      }
      
      // Stack trace for errors
      let stackHtml = '';
      if (log.stack) {
        stackHtml = \`<div class="log-meta" style="color: #f48771;">\${log.stack}</div>\`;
      }
      
      return \`
        <div class="log-entry \${level}">
          <span class="log-timestamp">\${timestamp}</span>
          <span class="log-level \${level}">\${level}</span>
          <span class="log-message">\${message}</span>
          \${metaHtml}
          \${stackHtml}
        </div>
      \`;
    }
    
    function updateStats(logs) {
      const stats = {
        total: logs.length,
        error: logs.filter(l => l.level === 'error').length,
        warn: logs.filter(l => l.level === 'warn').length,
        info: logs.filter(l => l.level === 'info').length,
        http: logs.filter(l => l.level === 'http').length,
      };
      
      document.getElementById('stats').innerHTML = \`
        <div class="stat-card">
          <div class="stat-label">Total Logs</div>
          <div class="stat-value">\${stats.total}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Errors</div>
          <div class="stat-value" style="color: #f48771;">\${stats.error}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Warnings</div>
          <div class="stat-value" style="color: #dcdcaa;">\${stats.warn}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Info</div>
          <div class="stat-value" style="color: #4ec9b0;">\${stats.info}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">HTTP</div>
          <div class="stat-value" style="color: #c586c0;">\${stats.http}</div>
        </div>
      \`;
    }
    
    async function loadLogs() {
      const container = document.getElementById('logsContainer');
      const level = document.getElementById('levelFilter').value;
      const limit = document.getElementById('limitSelect').value;
      
      container.innerHTML = '<div class="empty-state">Loading logs...</div>';
      
      try {
        const params = new URLSearchParams({ limit });
        if (level) params.append('level', level);
        
        const url = \`/v1/logs/recent?\${params}\`;
        const response = await fetch(url);
        
        if (!response.ok) {
          throw new Error(\`HTTP error! status: \${response.status}\`);
        }
        
        const result = await response.json();
        
        if (result.success && result.data && result.data.logs) {
          const logs = result.data.logs;
          
          if (logs.length === 0) {
            container.innerHTML = '<div class="empty-state">No logs available. Make some API requests to see logs here!</div>';
            updateStats([]);
            return;
          }
          
          container.innerHTML = logs.map(formatLogEntry).join('');
          updateStats(logs);
          
          // Auto-scroll to bottom
          container.scrollTop = container.scrollHeight;
        } else {
          const errorMsg = result.error || 'Failed to load logs';
          container.innerHTML = \`<div class="empty-state" style="color: #f48771;">\${errorMsg}</div>\`;
          console.error('Log loading error:', result);
        }
      } catch (error) {
        const errorMsg = error.message || 'Unknown error';
        container.innerHTML = \`<div class="empty-state" style="color: #f48771;">Error loading logs: \${errorMsg}<br><small>Check browser console for details</small></div>\`;
        console.error('Error loading logs:', error);
      }
    }
    
    function toggleAutoRefresh() {
      const checkbox = document.getElementById('autoRefresh');
      
      if (checkbox.checked) {
        autoRefreshInterval = setInterval(loadLogs, 5000);
      } else {
        if (autoRefreshInterval) {
          clearInterval(autoRefreshInterval);
          autoRefreshInterval = null;
        }
      }
    }
    
    // Load logs on page load
    loadLogs();
    
    // Cleanup on page unload
    window.addEventListener('beforeunload', () => {
      if (autoRefreshInterval) {
        clearInterval(autoRefreshInterval);
      }
    });
  </script>
</body>
</html>
    `;

    res.send(html);
  }

  /**
   * Serve UI log viewer HTML page (separate from API logs)
   */
  getUiLogViewer(_req: Request, res: Response): void {
    const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>JuaX UI Logs Viewer</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    
    body {
      font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
      background: #1e1e1e;
      color: #d4d4d4;
      padding: 20px;
    }
    
    .container {
      max-width: 1400px;
      margin: 0 auto;
    }
    
    header {
      background: #252526;
      padding: 20px;
      border-radius: 8px;
      margin-bottom: 20px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      flex-wrap: wrap;
      gap: 16px;
    }
    
    h1 {
      color: #4ec9b0;
      font-size: 24px;
    }
    
    .controls {
      display: flex;
      gap: 12px;
      align-items: center;
      flex-wrap: wrap;
    }
    
    select, button {
      padding: 8px 12px;
      background: #3c3c3c;
      color: #d4d4d4;
      border: 1px solid #555;
      border-radius: 4px;
      font-size: 14px;
      cursor: pointer;
    }
    
    button:hover {
      background: #4c4c4c;
    }
    
    .auto-refresh {
      display: flex;
      align-items: center;
      gap: 8px;
      color: #858585;
      font-size: 14px;
    }
    
    .stats {
      display: flex;
      gap: 16px;
      margin-bottom: 20px;
      flex-wrap: wrap;
    }
    
    .stat-card {
      background: #252526;
      padding: 16px;
      border-radius: 8px;
      flex: 1;
      min-width: 120px;
      text-align: center;
    }
    
    .stat-label {
      color: #858585;
      font-size: 12px;
      margin-bottom: 8px;
    }
    
    .stat-value {
      font-size: 24px;
      font-weight: bold;
      color: #4ec9b0;
    }
    
    .logs-container {
      background: #252526;
      border-radius: 8px;
      padding: 20px;
      max-height: 70vh;
      overflow-y: auto;
    }
    
    .log-entry {
      padding: 12px;
      margin-bottom: 8px;
      border-radius: 4px;
      border-left: 3px solid #555;
      background: #1e1e1e;
    }
    
    .log-entry.error {
      border-left-color: #f48771;
      background: #2a1f1f;
    }
    
    .log-entry.warn {
      border-left-color: #dcdcaa;
      background: #2a2a1f;
    }
    
    .log-entry.info {
      border-left-color: #4ec9b0;
    }
    
    .log-entry.debug {
      border-left-color: #569cd6;
    }
    
    .log-timestamp {
      color: #858585;
      font-size: 12px;
      margin-right: 12px;
    }
    
    .log-level {
      display: inline-block;
      padding: 2px 8px;
      border-radius: 3px;
      font-size: 11px;
      font-weight: bold;
      margin-right: 12px;
      text-transform: uppercase;
    }
    
    .log-level.error {
      background: #f48771;
      color: #1e1e1e;
    }
    
    .log-level.warn {
      background: #dcdcaa;
      color: #1e1e1e;
    }
    
    .log-level.info {
      background: #4ec9b0;
      color: #1e1e1e;
    }
    
    .log-level.debug {
      background: #569cd6;
      color: #1e1e1e;
    }
    
    .log-message {
      color: #d4d4d4;
      word-break: break-word;
    }
    
    .log-meta {
      margin-top: 8px;
      padding: 8px;
      background: #1a1a1a;
      border-radius: 4px;
      font-size: 12px;
      color: #858585;
      white-space: pre-wrap;
      font-family: 'Monaco', monospace;
    }
    
    .empty-state {
      text-align: center;
      padding: 40px;
      color: #858585;
    }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <h1>📱 JuaX UI Logs Viewer</h1>
      <div class="controls">
        <select id="levelFilter">
          <option value="">All Levels</option>
          <option value="error">Error</option>
          <option value="warn">Warning</option>
          <option value="info">Info</option>
          <option value="debug">Debug</option>
        </select>
        <select id="limitSelect">
          <option value="50">Last 50</option>
          <option value="100" selected>Last 100</option>
          <option value="200">Last 200</option>
          <option value="500">Last 500</option>
        </select>
        <button onclick="loadLogs()">Refresh</button>
        <div class="auto-refresh">
          <input type="checkbox" id="autoRefresh" onchange="toggleAutoRefresh()">
          <label for="autoRefresh">Auto-refresh (5s)</label>
        </div>
      </div>
    </header>
    
    <div class="stats" id="stats"></div>
    
    <div class="logs-container" id="logsContainer">
      <div class="empty-state">Loading logs...</div>
    </div>
  </div>

  <script>
    let autoRefreshInterval = null;
    
    function formatTimestamp(timestamp) {
      if (!timestamp) return '';
      try {
        let date;
        if (timestamp.includes('T')) {
          date = new Date(timestamp);
        } else {
          date = new Date(timestamp.replace(' ', 'T'));
        }
        if (isNaN(date.getTime())) {
          return timestamp;
        }
        return date.toLocaleTimeString('en-US', { 
          hour12: false,
          hour: '2-digit',
          minute: '2-digit',
          second: '2-digit'
        });
      } catch (e) {
        return timestamp;
      }
    }
    
    function formatLogEntry(log) {
      if (log.raw) {
        return \`<div class="log-entry">\${log.raw}</div>\`;
      }
      
      const level = log.level || 'info';
      const timestamp = formatTimestamp(log.timestamp);
      const message = log.message || '';
      
      const meta = { ...log };
      delete meta.timestamp;
      delete meta.level;
      delete meta.message;
      delete meta.stack;
      
      let metaHtml = '';
      if (Object.keys(meta).length > 0) {
        metaHtml = \`<div class="log-meta">\${JSON.stringify(meta, null, 2)}</div>\`;
      }
      
      let stackHtml = '';
      if (log.stack) {
        stackHtml = \`<div class="log-meta" style="color: #f48771;">\${log.stack}</div>\`;
      }
      
      return \`
        <div class="log-entry \${level}">
          <span class="log-timestamp">\${timestamp}</span>
          <span class="log-level \${level}">\${level}</span>
          <span class="log-message">\${message}</span>
          \${metaHtml}
          \${stackHtml}
        </div>
      \`;
    }
    
    function updateStats(logs) {
      const stats = {
        total: logs.length,
        error: logs.filter(l => l.level === 'error').length,
        warn: logs.filter(l => l.level === 'warn').length,
        info: logs.filter(l => l.level === 'info').length,
        debug: logs.filter(l => l.level === 'debug').length,
      };
      
      document.getElementById('stats').innerHTML = \`
        <div class="stat-card">
          <div class="stat-label">Total Logs</div>
          <div class="stat-value">\${stats.total}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Errors</div>
          <div class="stat-value" style="color: #f48771;">\${stats.error}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Warnings</div>
          <div class="stat-value" style="color: #dcdcaa;">\${stats.warn}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Info</div>
          <div class="stat-value" style="color: #4ec9b0;">\${stats.info}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Debug</div>
          <div class="stat-value" style="color: #569cd6;">\${stats.debug}</div>
        </div>
      \`;
    }
    
    async function loadLogs() {
      const container = document.getElementById('logsContainer');
      const level = document.getElementById('levelFilter').value;
      const limit = document.getElementById('limitSelect').value;
      
      container.innerHTML = '<div class="empty-state">Loading logs...</div>';
      
      try {
        const params = new URLSearchParams({ limit });
        if (level) params.append('level', level);
        
        const url = \`/v1/logs/ui/recent?\${params}\`;
        const response = await fetch(url);
        
        if (!response.ok) {
          throw new Error(\`HTTP error! status: \${response.status}\`);
        }
        
        const result = await response.json();
        
        if (result.success && result.data && result.data.logs) {
          const logs = result.data.logs;
          
          if (logs.length === 0) {
            container.innerHTML = '<div class="empty-state">No UI logs yet. Logs from the Flutter app will appear here.</div>';
            updateStats([]);
            return;
          }
          
          container.innerHTML = logs.map(formatLogEntry).join('');
          updateStats(logs);
          
          container.scrollTop = container.scrollHeight;
        } else {
          const errorMsg = result.error || 'Failed to load logs';
          container.innerHTML = \`<div class="empty-state" style="color: #f48771;">\${errorMsg}</div>\`;
          console.error('Log loading error:', result);
        }
      } catch (error) {
        const errorMsg = error.message || 'Unknown error';
        container.innerHTML = \`<div class="empty-state" style="color: #f48771;">Error loading logs: \${errorMsg}<br><small>Check browser console for details</small></div>\`;
        console.error('Error loading logs:', error);
      }
    }
    
    function toggleAutoRefresh() {
      const checkbox = document.getElementById('autoRefresh');
      
      if (checkbox.checked) {
        autoRefreshInterval = setInterval(loadLogs, 5000);
      } else {
        if (autoRefreshInterval) {
          clearInterval(autoRefreshInterval);
          autoRefreshInterval = null;
        }
      }
    }
    
    loadLogs();
    
    window.addEventListener('beforeunload', () => {
      if (autoRefreshInterval) {
        clearInterval(autoRefreshInterval);
      }
    });
  </script>
</body>
</html>
    `;

    res.send(html);
  }
}

export const logController = new LogController();
