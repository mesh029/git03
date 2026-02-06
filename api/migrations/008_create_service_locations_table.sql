-- Create service_locations table for pickup/dropoff stations
CREATE TABLE IF NOT EXISTS service_locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  type VARCHAR(50) NOT NULL CHECK (type IN ('pickup', 'dropoff', 'both')),
  location_latitude DECIMAL(10, 7) NOT NULL CHECK (location_latitude BETWEEN -90 AND 90),
  location_longitude DECIMAL(10, 7) NOT NULL CHECK (location_longitude BETWEEN -180 AND 180),
  address VARCHAR(500) NOT NULL,
  area_label VARCHAR(255) NOT NULL,
  city VARCHAR(100) NOT NULL DEFAULT 'Kisumu',
  is_active BOOLEAN DEFAULT TRUE,
  operating_hours JSONB, -- e.g., {"monday": {"open": "08:00", "close": "18:00"}, ...}
  contact_phone VARCHAR(20),
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_service_locations_type ON service_locations(type);
CREATE INDEX IF NOT EXISTS idx_service_locations_active ON service_locations(is_active);
CREATE INDEX IF NOT EXISTS idx_service_locations_city ON service_locations(city);
CREATE INDEX IF NOT EXISTS idx_service_locations_location ON service_locations(location_latitude, location_longitude);

-- Create trigger for service_locations updated_at
CREATE TRIGGER update_service_locations_updated_at
  BEFORE UPDATE ON service_locations
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Insert sample service locations for Kisumu
INSERT INTO service_locations (name, type, location_latitude, location_longitude, address, area_label, city, is_active, contact_phone) VALUES
  ('Milimani Pickup Station', 'both', -0.0917, 34.7680, 'Milimani Road, Near Milimani Shopping Centre', 'Milimani', 'Kisumu', TRUE, '+254712345678'),
  ('Town Centre Drop-off Point', 'dropoff', -0.0917, 34.7680, 'Oginga Odinga Street, Town Centre', 'Town Centre', 'Kisumu', TRUE, '+254712345679'),
  ('Nyalenda Service Station', 'both', -0.1200, 34.7500, 'Nyalenda Market Area', 'Nyalenda', 'Kisumu', TRUE, '+254712345680'),
  ('Kibos Road Pickup Point', 'pickup', -0.1000, 34.7800, 'Kibos Road, Near Kibos Mall', 'Kibos', 'Kisumu', TRUE, '+254712345681');
