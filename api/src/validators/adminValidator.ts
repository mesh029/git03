import Joi from 'joi';
import { OrderStatus } from '../models/Order';
import { SubscriptionStatus, SubscriptionTier } from '../models/Subscription';

export const updateUserRoleSchema = Joi.object({
  isAdmin: Joi.boolean().optional(),
  isAgent: Joi.boolean().optional(),
}).min(1).messages({
  'object.min': 'At least one role field must be provided',
});

export const updateOrderStatusSchema = Joi.object({
  status: Joi.string()
    .valid(OrderStatus.PENDING, OrderStatus.CANCELLED)
    .required()
    .messages({
      'any.only': 'Status must be pending or cancelled',
      'any.required': 'Status is required',
    }),
});

export const adminUsersQuerySchema = Joi.object({
  role: Joi.string().valid('regular', 'agent', 'admin').optional(),
  limit: Joi.number().integer().min(1).max(100).optional().default(20),
  offset: Joi.number().integer().min(0).optional().default(0),
});

export const adminOrdersQuerySchema = Joi.object({
  status: Joi.string().valid('pending', 'cancelled').optional(),
  type: Joi.string().valid('cleaning', 'laundry', 'property_booking').optional(),
  userId: Joi.string().uuid().optional(),
  limit: Joi.number().integer().min(1).max(100).optional().default(20),
  offset: Joi.number().integer().min(0).optional().default(0),
});

export const adminPropertiesQuerySchema = Joi.object({
  isAvailable: Joi.boolean().optional(),
  type: Joi.string().valid('apartment', 'bnb').optional(),
  agentId: Joi.string().uuid().optional(),
  limit: Joi.number().integer().min(1).max(100).optional().default(20),
  offset: Joi.number().integer().min(0).optional().default(0),
});

export const adminSubscriptionsQuerySchema = Joi.object({
  status: Joi.string().valid(...Object.values(SubscriptionStatus)).optional(),
  tier: Joi.string().valid(...Object.values(SubscriptionTier)).optional(),
  userId: Joi.string().uuid().optional(),
  limit: Joi.number().integer().min(1).max(100).optional().default(20),
  offset: Joi.number().integer().min(0).optional().default(0),
});

export const updateSubscriptionStatusSchema = Joi.object({
  status: Joi.string()
    .valid(...Object.values(SubscriptionStatus))
    .required()
    .messages({
      'any.only': 'Invalid subscription status',
      'any.required': 'Status is required',
    }),
});
