import { OrderStatus } from './Order';

export interface OrderStatusHistory {
  id: string;
  order_id: string;
  status: OrderStatus;
  updated_by: string | null;
  notes: string | null;
  created_at: Date;
}

export interface OrderTracking {
  id: string;
  order_id: string;
  service_provider_id: string | null;
  current_location_latitude: number | null;
  current_location_longitude: number | null;
  current_location_label: string | null;
  estimated_completion_time: Date | null;
  last_updated_at: Date;
  created_at: Date;
}

export interface StatusHistoryResponse {
  id: string;
  status: OrderStatus;
  updatedBy: string | null;
  notes: string | null;
  createdAt: string;
}

export interface TrackingLocation {
  latitude: number;
  longitude: number;
  label?: string;
}

export interface OrderTrackingResponse {
  orderId: string;
  currentStatus: OrderStatus;
  statusHistory: StatusHistoryResponse[];
  serviceProvider: {
    id: string;
    name: string;
    email: string;
  } | null;
  currentLocation: TrackingLocation | null;
  estimatedCompletionTime: string | null;
  lastUpdatedAt: string;
}

export interface UpdateOrderStatusInput {
  status: OrderStatus;
  notes?: string;
}

export interface UpdateLocationInput {
  latitude: number;
  longitude: number;
  label?: string;
}
