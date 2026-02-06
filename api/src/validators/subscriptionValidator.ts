import Joi from 'joi';
import { SubscriptionTier, BillingPeriod } from '../models/Subscription';

export const upgradeSubscriptionSchema = Joi.object({
  tier: Joi.string()
    .valid(...Object.values(SubscriptionTier))
    .required()
    .messages({
      'any.only': 'Invalid subscription tier',
      'any.required': 'Tier is required',
    }),
  billingPeriod: Joi.string()
    .valid(...Object.values(BillingPeriod))
    .required()
    .messages({
      'any.only': 'Invalid billing period',
      'any.required': 'Billing period is required',
    }),
});

export const downgradeSubscriptionSchema = Joi.object({
  tier: Joi.string()
    .valid(SubscriptionTier.FREEMIUM)
    .required()
    .messages({
      'any.only': 'Can only downgrade to freemium tier',
      'any.required': 'Tier is required',
    }),
});

export const checkAccessQuerySchema = Joi.object({
  feature: Joi.string().required().messages({
    'any.required': 'Feature name is required',
  }),
});

export const adminSubscriptionsQuerySchema = Joi.object({
  status: Joi.string().valid('active', 'expired', 'cancelled', 'trial').optional(),
  tier: Joi.string().valid(...Object.values(SubscriptionTier)).optional(),
  userId: Joi.string().uuid().optional(),
  limit: Joi.number().integer().min(1).max(100).optional().default(20),
  offset: Joi.number().integer().min(0).optional().default(0),
});

export const updateSubscriptionStatusSchema = Joi.object({
  status: Joi.string()
    .valid('active', 'expired', 'cancelled', 'trial')
    .required()
    .messages({
      'any.only': 'Invalid subscription status',
      'any.required': 'Status is required',
    }),
});
