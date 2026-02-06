-- Create property_bookings table
CREATE TABLE IF NOT EXISTS property_bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  check_in TIMESTAMP NOT NULL,
  check_out TIMESTAMP NOT NULL,
  guests INTEGER,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(property_id, check_in, check_out)
);

-- Create indexes for efficient conflict detection
CREATE INDEX IF NOT EXISTS idx_bookings_property_id ON property_bookings(property_id);
CREATE INDEX IF NOT EXISTS idx_bookings_order_id ON property_bookings(order_id);
CREATE INDEX IF NOT EXISTS idx_bookings_dates ON property_bookings(property_id, check_in, check_out);

-- Add constraint to ensure check_out is after check_in
ALTER TABLE property_bookings
  ADD CONSTRAINT check_dates_valid CHECK (check_out > check_in);
