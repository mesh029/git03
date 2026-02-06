-- Create order_status_history table
CREATE TABLE IF NOT EXISTS order_status_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  status VARCHAR(50) NOT NULL,
  updated_by UUID REFERENCES users(id) ON DELETE SET NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create order_tracking table
CREATE TABLE IF NOT EXISTS order_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  service_provider_id UUID REFERENCES users(id) ON DELETE SET NULL,
  current_location_latitude DECIMAL(10, 7),
  current_location_longitude DECIMAL(10, 7),
  current_location_label VARCHAR(255),
  estimated_completion_time TIMESTAMP,
  last_updated_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(order_id)
);

-- Create indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_order_status_history_order_id ON order_status_history(order_id);
CREATE INDEX IF NOT EXISTS idx_order_status_history_created_at ON order_status_history(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_order_tracking_order_id ON order_tracking(order_id);
CREATE INDEX IF NOT EXISTS idx_order_tracking_service_provider_id ON order_tracking(service_provider_id);
CREATE INDEX IF NOT EXISTS idx_order_tracking_last_updated ON order_tracking(last_updated_at DESC);

-- Function to auto-create tracking record when order is created
CREATE OR REPLACE FUNCTION create_order_tracking()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO order_tracking (order_id)
  VALUES (NEW.id);
  
  INSERT INTO order_status_history (order_id, status, updated_by)
  VALUES (NEW.id, NEW.status, NEW.owner_id);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-create tracking when order is created
CREATE TRIGGER create_tracking_on_order_insert
  AFTER INSERT ON orders
  FOR EACH ROW
  EXECUTE FUNCTION create_order_tracking();

-- Function to record status changes
CREATE OR REPLACE FUNCTION record_status_change()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO order_status_history (order_id, status, updated_by)
    VALUES (NEW.id, NEW.status, NEW.owner_id);
    
    UPDATE order_tracking
    SET last_updated_at = NOW()
    WHERE order_id = NEW.id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to record status changes
CREATE TRIGGER record_order_status_change
  AFTER UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION record_status_change();
