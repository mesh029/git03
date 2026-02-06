import Joi from 'joi';

export const geocodeQuerySchema = Joi.object({
  address: Joi.string().min(1).max(500).required().messages({
    'string.min': 'Address must be at least 1 character',
    'string.max': 'Address must be 500 characters or less',
    'any.required': 'Address query parameter is required',
  }),
  country: Joi.string().length(2).optional().messages({
    'string.length': 'Country code must be 2 characters (ISO 3166-1 alpha-2)',
  }),
});

export const reverseGeocodeQuerySchema = Joi.object({
  lat: Joi.number().min(-90).max(90).required().messages({
    'number.min': 'Latitude must be between -90 and 90',
    'number.max': 'Latitude must be between -90 and 90',
    'any.required': 'Latitude query parameter is required',
  }),
  lng: Joi.number().min(-180).max(180).required().messages({
    'number.min': 'Longitude must be between -180 and 180',
    'number.max': 'Longitude must be between -180 and 180',
    'any.required': 'Longitude query parameter is required',
  }),
});

export const distanceQuerySchema = Joi.object({
  fromLat: Joi.number().min(-90).max(90).required().messages({
    'any.required': 'fromLat query parameter is required',
  }),
  fromLng: Joi.number().min(-180).max(180).required().messages({
    'any.required': 'fromLng query parameter is required',
  }),
  toLat: Joi.number().min(-90).max(90).required().messages({
    'any.required': 'toLat query parameter is required',
  }),
  toLng: Joi.number().min(-180).max(180).required().messages({
    'any.required': 'toLng query parameter is required',
  }),
});

export const validateCoordinatesQuerySchema = Joi.object({
  lat: Joi.number().min(-90).max(90).required().messages({
    'any.required': 'Latitude query parameter is required',
  }),
  lng: Joi.number().min(-180).max(180).required().messages({
    'any.required': 'Longitude query parameter is required',
  }),
});
