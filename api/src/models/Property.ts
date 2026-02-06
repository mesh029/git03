export enum PropertyType {
  APARTMENT = 'apartment',
  BNB = 'bnb',
}

export interface Property {
  id: string;
  agent_id: string;
  type: PropertyType;
  title: string;
  location_latitude: number;
  location_longitude: number;
  area_label: string;
  is_available: boolean;
  price_label?: string;
  rating?: number;
  traction: number;
  amenities?: string[];
  house_rules?: string[];
  images?: string[];
  created_at: Date;
  updated_at: Date;
}

export interface CreatePropertyInput {
  type: PropertyType;
  title: string;
  location_latitude: number;
  location_longitude: number;
  area_label: string;
  price_label?: string;
  amenities?: string[];
  house_rules?: string[];
  images?: string[];
}

export interface PropertyResponse {
  id: string;
  agent_id: string;
  type: PropertyType;
  title: string;
  location: {
    latitude: number;
    longitude: number;
    label: string;
  };
  is_available: boolean;
  price_label?: string;
  rating?: number;
  traction: number;
  amenities?: string[];
  house_rules?: string[];
  images?: string[];
  created_at: string;
  updated_at: string;
}
