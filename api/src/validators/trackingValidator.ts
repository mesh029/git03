import Joi from 'joi';
import { OrderStatus } from '../models/Order';

export const updateOrderStatusSchema = Joi.object({
  status: Joi.string()
    .valid(...Object.values(OrderStatus))
    .required()
    .messages({
      'any.only': 'Invalid order status',
      'any.required': 'Status is required',
    }),
  notes: Joi.string().max(500).optional().messages({
    'string.max': 'Notes cannot exceed 500 characters',
  }),
});

export const updateLocationSchema = Joi.object({
  latitude: Joi.number()
    .min(-90)
    .max(90)
    .required()
    .messages({
      'number.min': 'Latitude must be between -90 and 90',
      'number.max': 'Latitude must be between -90 and 90',
      'any.required': 'Latitude is required',
    }),
  longitude: Joi.number()
    .min(-180)
    .max(180)
    .required()
    .messages({
      'number.min': 'Longitude must be between -180 and 180',
      'number.max': 'Longitude must be between -180 and 180',
      'any.required': 'Longitude is required',
    }),
  label: Joi.string().max(255).optional().messages({
    'string.max': 'Location label cannot exceed 255 characters',
  }),
});

export const assignServiceProviderSchema = Joi.object({
  serviceProviderId: Joi.string().uuid().required().messages({
    'string.guid': 'Invalid service provider ID format',
    'any.required': 'Service provider ID is required',
  }),
});
