export enum OrderType {
  CLEANING = 'cleaning',
  LAUNDRY = 'laundry',
  PROPERTY_BOOKING = 'property_booking',
}

export enum OrderStatus {
  PENDING = 'pending',
  CANCELLED = 'cancelled',
}

export interface Location {
  latitude: number;
  longitude: number;
  label: string;
}

export interface CleaningDetails {
  service: string;
  rooms?: number;
}

export interface LaundryDetails {
  serviceType: string;
  quantity?: number;
  items?: string[];
}

export interface PropertyBookingDetails {
  propertyId: string;
  checkIn: string; // ISO8601 datetime
  checkOut: string; // ISO8601 datetime
  guests?: number;
}

export type OrderDetails = CleaningDetails | LaundryDetails | PropertyBookingDetails;

export interface Order {
  id: string;
  owner_id: string;
  type: OrderType;
  status: OrderStatus;
  location: Location;
  details: OrderDetails;
  created_at: Date;
  updated_at: Date;
  cancelled_at?: Date;
}

export interface CreateOrderInput {
  type: OrderType;
  location: Location;
  details: OrderDetails;
}

export interface OrderResponse {
  id: string;
  owner_id: string;
  status: OrderStatus;
  type: OrderType;
  location: Location;
  details: OrderDetails;
  created_at: string;
  updated_at: string;
  cancelled_at?: string;
}
