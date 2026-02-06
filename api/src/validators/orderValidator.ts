import Joi from 'joi';
import { OrderType, CreateOrderInput } from '../models/Order';

const locationSchema = Joi.object({
  latitude: Joi.number().min(-90).max(90).required().messages({
    'number.min': 'Latitude must be between -90 and 90',
    'number.max': 'Latitude must be between -90 and 90',
    'any.required': 'Latitude is required',
  }),
  longitude: Joi.number().min(-180).max(180).required().messages({
    'number.min': 'Longitude must be between -180 and 180',
    'number.max': 'Longitude must be between -180 and 180',
    'any.required': 'Longitude is required',
  }),
  label: Joi.string().min(1).max(255).required().messages({
    'string.min': 'Location label is required',
    'string.max': 'Location label must be 255 characters or less',
    'any.required': 'Location label is required',
  }),
});

const cleaningDetailsSchema = Joi.object({
  service: Joi.string().min(1).max(100).required().messages({
    'any.required': 'Service is required',
  }),
  rooms: Joi.number().integer().min(1).max(20).optional(),
});

const laundryDetailsSchema = Joi.object({
  serviceType: Joi.string().min(1).max(100).required().messages({
    'any.required': 'Service type is required',
  }),
  quantity: Joi.number().integer().min(1).max(100).optional(),
  items: Joi.array().items(Joi.string().min(1).max(50)).max(20).optional(),
});

const propertyBookingDetailsSchema = Joi.object({
  propertyId: Joi.string().uuid().required().messages({
    'string.guid': 'Property ID must be a valid UUID',
    'any.required': 'Property ID is required',
  }),
  checkIn: Joi.date().iso().greater('now').required().messages({
    'date.greater': 'Check-in date must be in the future',
    'any.required': 'Check-in date is required',
  }),
  checkOut: Joi.date().iso().greater(Joi.ref('checkIn')).required().messages({
    'date.greater': 'Check-out date must be after check-in date',
    'any.required': 'Check-out date is required',
  }),
  guests: Joi.number().integer().min(1).max(20).optional(),
});

export const createOrderSchema = Joi.object<CreateOrderInput>({
  type: Joi.string()
    .valid(OrderType.CLEANING, OrderType.LAUNDRY, OrderType.PROPERTY_BOOKING)
    .required()
    .messages({
      'any.only': 'Type must be cleaning, laundry, or property_booking',
      'any.required': 'Type is required',
    }),
  location: locationSchema.required(),
  details: Joi.when('type', {
    is: OrderType.CLEANING,
    then: cleaningDetailsSchema.required(),
    otherwise: Joi.when('type', {
      is: OrderType.LAUNDRY,
      then: laundryDetailsSchema.required(),
      otherwise: propertyBookingDetailsSchema.required(),
    }),
  }).messages({
    'any.required': 'Details are required',
  }),
});

export const getOrdersQuerySchema = Joi.object({
  status: Joi.string().valid('pending', 'cancelled').optional(),
  type: Joi.string().valid('cleaning', 'laundry', 'property_booking').optional(),
  limit: Joi.number().integer().min(1).max(100).optional().default(20),
  offset: Joi.number().integer().min(0).optional().default(0),
});
