-- Create properties table
CREATE TABLE IF NOT EXISTS properties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL CHECK (type IN ('apartment', 'bnb')),
  title VARCHAR(255) NOT NULL,
  location_latitude DECIMAL(10, 7) NOT NULL,
  location_longitude DECIMAL(10, 7) NOT NULL,
  area_label VARCHAR(255) NOT NULL,
  is_available BOOLEAN DEFAULT TRUE,
  price_label VARCHAR(100),
  rating DECIMAL(3, 2),
  traction INTEGER DEFAULT 0,
  amenities TEXT[],
  house_rules TEXT[],
  images TEXT[],
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_properties_agent_id ON properties(agent_id);
CREATE INDEX IF NOT EXISTS idx_properties_available ON properties(is_available);
CREATE INDEX IF NOT EXISTS idx_properties_type ON properties(type);

-- Create spatial index for location queries (requires PostGIS extension)
-- If PostGIS is not available, use regular index
CREATE INDEX IF NOT EXISTS idx_properties_location ON properties(location_latitude, location_longitude);

-- Create trigger for properties updated_at
CREATE TRIGGER update_properties_updated_at
  BEFORE UPDATE ON properties
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
