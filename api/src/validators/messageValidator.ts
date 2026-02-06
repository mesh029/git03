import Joi from 'joi';
import { ConversationType } from '../models/Message';

export const createConversationSchema = Joi.object({
  orderId: Joi.string().uuid().optional().messages({
    'string.guid': 'Invalid order ID format',
  }),
  type: Joi.string()
    .valid(...Object.values(ConversationType))
    .required()
    .messages({
      'any.only': 'Invalid conversation type',
      'any.required': 'Conversation type is required',
    }),
  subject: Joi.string().max(255).optional().messages({
    'string.max': 'Subject cannot exceed 255 characters',
  }),
  participantIds: Joi.array()
    .items(Joi.string().uuid())
    .min(1)
    .required()
    .messages({
      'array.min': 'At least one participant is required',
      'any.required': 'Participant IDs are required',
    }),
});

export const sendMessageSchema = Joi.object({
  content: Joi.string()
    .trim()
    .min(1)
    .max(5000)
    .required()
    .messages({
      'string.min': 'Message content cannot be empty',
      'string.max': 'Message content cannot exceed 5000 characters',
      'any.required': 'Message content is required',
    }),
});

export const getConversationsQuerySchema = Joi.object({
  type: Joi.string().valid(...Object.values(ConversationType)).optional(),
  orderId: Joi.string().uuid().optional(),
  limit: Joi.number().integer().min(1).max(100).optional().default(20),
  offset: Joi.number().integer().min(0).optional().default(0),
});

export const getMessagesQuerySchema = Joi.object({
  limit: Joi.number().integer().min(1).max(100).optional().default(50),
  offset: Joi.number().integer().min(0).optional().default(0),
});

export const adminConversationsQuerySchema = Joi.object({
  type: Joi.string().valid(...Object.values(ConversationType)).optional(),
  orderId: Joi.string().uuid().optional(),
  userId: Joi.string().uuid().optional(),
  limit: Joi.number().integer().min(1).max(100).optional().default(20),
  offset: Joi.number().integer().min(0).optional().default(0),
});
