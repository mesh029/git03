import { Router } from 'express';
import { logController } from '../controllers/logController';

const router = Router();

// API Log viewer page
router.get('/viewer', logController.getLogViewer.bind(logController));

// UI Log viewer page
router.get('/ui/viewer', logController.getUiLogViewer.bind(logController));

// Get list of log files
router.get('/files', logController.getLogFiles.bind(logController));

// Get specific log file
router.get('/files/:filename', logController.getLogFile.bind(logController));

// Get recent API logs (from combined.log)
router.get('/recent', logController.getRecentLogs.bind(logController));

// Get recent UI logs (from ui.log)
router.get('/ui/recent', logController.getRecentUiLogs.bind(logController));

// Receive UI log from Flutter app
router.post('/ui', logController.receiveUiLog.bind(logController));

export default router;
