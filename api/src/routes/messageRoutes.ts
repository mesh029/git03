import { Router } from 'express';
import { messageController } from '../controllers/messageController';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validator';
import { validateQuery } from '../middleware/queryValidator';
import {
  createConversationSchema,
  sendMessageSchema,
  getConversationsQuerySchema,
  getMessagesQuerySchema,
} from '../validators/messageValidator';
import { apiLimiter } from '../middleware/rateLimiter';

const router = Router();

// All message routes require authentication
router.use(authenticate);
router.use(apiLimiter);

// Get user's conversations
router.get(
  '/conversations',
  validateQuery(getConversationsQuerySchema),
  messageController.getConversations.bind(messageController)
);

// Get conversation by ID
router.get(
  '/conversations/:id',
  messageController.getConversation.bind(messageController)
);

// Get messages in conversation
router.get(
  '/conversations/:id/messages',
  validateQuery(getMessagesQuerySchema),
  messageController.getMessages.bind(messageController)
);

// Create new conversation
router.post(
  '/conversations',
  validate(createConversationSchema),
  messageController.createConversation.bind(messageController)
);

// Send message in conversation
router.post(
  '/conversations/:id/messages',
  validate(sendMessageSchema),
  messageController.sendMessage.bind(messageController)
);

// Mark message as read
router.patch(
  '/:id/read',
  messageController.markMessageAsRead.bind(messageController)
);

// Mark all messages in conversation as read
router.patch(
  '/conversations/:id/read',
  messageController.markConversationAsRead.bind(messageController)
);

export default router;
