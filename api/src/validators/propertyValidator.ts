import Joi from 'joi';
import { PropertyType, CreatePropertyInput, UpdatePropertyInput } from '../models/Property';

export const createPropertySchema = Joi.object<CreatePropertyInput>({
  type: Joi.string()
    .valid(PropertyType.APARTMENT, PropertyType.BNB)
    .required()
    .messages({
      'any.only': 'Type must be apartment or bnb',
      'any.required': 'Type is required',
    }),
  title: Joi.string().min(1).max(255).required().messages({
    'string.min': 'Title is required',
    'string.max': 'Title must be 255 characters or less',
    'any.required': 'Title is required',
  }),
  location_latitude: Joi.number().min(-90).max(90).required().messages({
    'number.min': 'Latitude must be between -90 and 90',
    'number.max': 'Latitude must be between -90 and 90',
    'any.required': 'Location latitude is required',
  }),
  location_longitude: Joi.number().min(-180).max(180).required().messages({
    'number.min': 'Longitude must be between -180 and 180',
    'number.max': 'Longitude must be between -180 and 180',
    'any.required': 'Location longitude is required',
  }),
  area_label: Joi.string().min(1).max(255).required().messages({
    'string.min': 'Area label is required',
    'string.max': 'Area label must be 255 characters or less',
    'any.required': 'Area label is required',
  }),
  price_label: Joi.string().max(100).optional().allow(null, ''),
  amenities: Joi.array().items(Joi.string().min(1).max(50)).max(20).optional(),
  house_rules: Joi.array().items(Joi.string().min(1).max(200)).max(30).optional(),
  images: Joi.array().items(Joi.string().uri().max(500)).max(20).optional(),
});

export const updatePropertySchema = Joi.object<UpdatePropertyInput>({
  title: Joi.string().min(1).max(255).optional(),
  location_latitude: Joi.number().min(-90).max(90).optional(),
  location_longitude: Joi.number().min(-180).max(180).optional(),
  area_label: Joi.string().min(1).max(255).optional(),
  price_label: Joi.string().max(100).optional().allow(null, ''),
  amenities: Joi.array().items(Joi.string().min(1).max(50)).max(20).optional(),
  house_rules: Joi.array().items(Joi.string().min(1).max(200)).max(30).optional(),
  images: Joi.array().items(Joi.string().uri().max(500)).max(20).optional(),
}).min(1).messages({
  'object.min': 'At least one field must be provided for update',
});

export const getPropertiesQuerySchema = Joi.object({
  isAvailable: Joi.boolean().optional(),
  type: Joi.string().valid('apartment', 'bnb').optional(),
  agentId: Joi.string().uuid().optional(),
  areaLabel: Joi.string().min(1).max(255).optional(),
  limit: Joi.number().integer().min(1).max(100).optional().default(20),
  offset: Joi.number().integer().min(0).optional().default(0),
});
