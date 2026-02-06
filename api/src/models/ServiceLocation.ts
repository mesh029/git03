export enum ServiceLocationType {
  PICKUP = 'pickup',
  DROPOFF = 'dropoff',
  BOTH = 'both',
}

export interface OperatingHours {
  [day: string]: {
    open: string; // HH:mm format
    close: string; // HH:mm format
    closed?: boolean;
  };
}

export interface ServiceLocation {
  id: string;
  name: string;
  type: ServiceLocationType;
  location_latitude: number;
  location_longitude: number;
  address: string;
  area_label: string;
  city: string;
  is_active: boolean;
  operating_hours?: OperatingHours;
  contact_phone?: string;
  notes?: string;
  created_at: Date;
  updated_at: Date;
}

export interface CreateServiceLocationInput {
  name: string;
  type: ServiceLocationType;
  location_latitude: number;
  location_longitude: number;
  address: string;
  area_label: string;
  city?: string;
  operating_hours?: OperatingHours;
  contact_phone?: string;
  notes?: string;
}

export interface UpdateServiceLocationInput {
  name?: string;
  type?: ServiceLocationType;
  location_latitude?: number;
  location_longitude?: number;
  address?: string;
  area_label?: string;
  city?: string;
  is_active?: boolean;
  operating_hours?: OperatingHours;
  contact_phone?: string;
  notes?: string;
}

export interface ServiceLocationResponse {
  id: string;
  name: string;
  type: ServiceLocationType;
  location: {
    latitude: number;
    longitude: number;
    address: string;
    area_label: string;
    city: string;
  };
  is_active: boolean;
  operating_hours?: OperatingHours;
  contact_phone?: string;
  notes?: string;
  distance_km?: number; // Calculated distance when searching nearby
  created_at: string;
  updated_at: string;
}

export interface NearbyServiceLocationQuery {
  latitude: number;
  longitude: number;
  radius_km?: number; // Default 10km
  type?: ServiceLocationType;
  limit?: number; // Default 10
}
