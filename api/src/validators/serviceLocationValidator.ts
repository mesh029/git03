import Joi from 'joi';
import { ServiceLocationType } from '../models/ServiceLocation';

const operatingHoursSchema = Joi.object().pattern(
  Joi.string(),
  Joi.object({
    open: Joi.string().pattern(/^([0-1][0-9]|2[0-3]):[0-5][0-9]$/).required(),
    close: Joi.string().pattern(/^([0-1][0-9]|2[0-3]):[0-5][0-9]$/).required(),
    closed: Joi.boolean().optional(),
  })
);

export const createServiceLocationSchema = Joi.object({
  name: Joi.string().min(1).max(255).required().messages({
    'any.required': 'Name is required',
    'string.min': 'Name must be at least 1 character',
    'string.max': 'Name must be 255 characters or less',
  }),
  type: Joi.string()
    .valid(...Object.values(ServiceLocationType))
    .required()
    .messages({
      'any.only': `Type must be one of: ${Object.values(ServiceLocationType).join(', ')}`,
      'any.required': 'Type is required',
    }),
  location_latitude: Joi.number().min(-90).max(90).required().messages({
    'number.min': 'Latitude must be between -90 and 90',
    'number.max': 'Latitude must be between -90 and 90',
    'any.required': 'Latitude is required',
  }),
  location_longitude: Joi.number().min(-180).max(180).required().messages({
    'number.min': 'Longitude must be between -180 and 180',
    'number.max': 'Longitude must be between -180 and 180',
    'any.required': 'Longitude is required',
  }),
  address: Joi.string().min(1).max(500).required().messages({
    'any.required': 'Address is required',
    'string.max': 'Address must be 500 characters or less',
  }),
  area_label: Joi.string().min(1).max(255).required().messages({
    'any.required': 'Area label is required',
  }),
  city: Joi.string().max(100).optional(),
  operating_hours: operatingHoursSchema.optional(),
  contact_phone: Joi.string().max(20).optional(),
  notes: Joi.string().max(1000).optional(),
});

export const updateServiceLocationSchema = Joi.object({
  name: Joi.string().min(1).max(255).optional(),
  type: Joi.string()
    .valid(...Object.values(ServiceLocationType))
    .optional(),
  location_latitude: Joi.number().min(-90).max(90).optional(),
  location_longitude: Joi.number().min(-180).max(180).optional(),
  address: Joi.string().min(1).max(500).optional(),
  area_label: Joi.string().min(1).max(255).optional(),
  city: Joi.string().max(100).optional(),
  is_active: Joi.boolean().optional(),
  operating_hours: operatingHoursSchema.optional(),
  contact_phone: Joi.string().max(20).optional(),
  notes: Joi.string().max(1000).optional(),
});

export const nearbyServiceLocationQuerySchema = Joi.object({
  latitude: Joi.number().min(-90).max(90).required(),
  longitude: Joi.number().min(-180).max(180).required(),
  radius_km: Joi.number().min(0.1).max(100).optional(),
  type: Joi.string()
    .valid(...Object.values(ServiceLocationType))
    .optional(),
  limit: Joi.number().integer().min(1).max(50).optional(),
});
