import { Request, Response, NextFunction } from 'express';
import { messageService } from '../services/messageService';
import { CreateConversationInput, SendMessageInput, ConversationType } from '../models/Message';

export class MessageController {
  /**
   * Get user's conversations
   * GET /v1/messages/conversations
   */
  async getConversations(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          error: {
            code: 'AUTH_REQUIRED',
            message: 'Authentication required',
          },
        });
        return;
      }

      const filters = {
        type: req.query.type as ConversationType | undefined,
        orderId: req.query.orderId as string | undefined,
        limit: req.query.limit ? parseInt(req.query.limit as string, 10) : undefined,
        offset: req.query.offset ? parseInt(req.query.offset as string, 10) : undefined,
      };

      const result = await messageService.getUserConversations(req.user.id, filters);

      res.status(200).json({
        success: true,
        data: {
          conversations: result.conversations,
          pagination: {
            limit: result.limit,
            offset: result.offset,
            total: result.total,
          },
        },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get conversation by ID
   * GET /v1/messages/conversations/:id
   */
  async getConversation(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          error: {
            code: 'AUTH_REQUIRED',
            message: 'Authentication required',
          },
        });
        return;
      }

      const conversationId = req.params.id;
      const conversation = await messageService.getConversationById(conversationId, req.user.id);

      res.status(200).json({
        success: true,
        data: conversation,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get messages in conversation
   * GET /v1/messages/conversations/:id/messages
   */
  async getMessages(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          error: {
            code: 'AUTH_REQUIRED',
            message: 'Authentication required',
          },
        });
        return;
      }

      const conversationId = req.params.id;
      const filters = {
        limit: req.query.limit ? parseInt(req.query.limit as string, 10) : undefined,
        offset: req.query.offset ? parseInt(req.query.offset as string, 10) : undefined,
      };

      const result = await messageService.getConversationMessages(
        conversationId,
        req.user.id,
        filters
      );

      res.status(200).json({
        success: true,
        data: {
          messages: result.messages,
          pagination: {
            limit: result.limit,
            offset: result.offset,
            total: result.total,
          },
        },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Create new conversation
   * POST /v1/messages/conversations
   */
  async createConversation(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          error: {
            code: 'AUTH_REQUIRED',
            message: 'Authentication required',
          },
        });
        return;
      }

      const input: CreateConversationInput = req.body;
      const conversation = await messageService.createConversation(req.user.id, input);

      res.status(201).json({
        success: true,
        data: conversation,
        message: 'Conversation created successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Send message in conversation
   * POST /v1/messages/conversations/:id/messages
   */
  async sendMessage(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          error: {
            code: 'AUTH_REQUIRED',
            message: 'Authentication required',
          },
        });
        return;
      }

      const conversationId = req.params.id;
      const input: SendMessageInput = req.body;
      const message = await messageService.sendMessage(conversationId, req.user.id, input);

      res.status(201).json({
        success: true,
        data: message,
        message: 'Message sent successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Mark message as read
   * PATCH /v1/messages/:id/read
   */
  async markMessageAsRead(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          error: {
            code: 'AUTH_REQUIRED',
            message: 'Authentication required',
          },
        });
        return;
      }

      const messageId = req.params.id;
      const message = await messageService.markMessageAsRead(messageId, req.user.id);

      res.status(200).json({
        success: true,
        data: message,
        message: 'Message marked as read',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Mark all messages in conversation as read
   * PATCH /v1/messages/conversations/:id/read
   */
  async markConversationAsRead(
    req: Request,
    res: Response,
    next: NextFunction
  ): Promise<void> {
    try {
      if (!req.user) {
        res.status(401).json({
          success: false,
          error: {
            code: 'AUTH_REQUIRED',
            message: 'Authentication required',
          },
        });
        return;
      }

      const conversationId = req.params.id;
      await messageService.markConversationAsRead(conversationId, req.user.id);

      res.status(200).json({
        success: true,
        message: 'All messages marked as read',
      });
    } catch (error) {
      next(error);
    }
  }
}

export const messageController = new MessageController();
