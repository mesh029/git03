# Property Images & Service Locations Implementation

## Overview

This document describes the implementation of two major features:
1. **Property Image Management** - Upload and manage images for properties (BNBs and apartments)
2. **Service Locations/Pickup Stations** - Database and API for laundry pickup/dropoff stations

---

## 🖼️ Property Image Management

### Features Implemented

✅ **Image Upload**
- Upload images for properties (JPEG, PNG, WebP)
- Maximum file size: 5MB
- Automatic file validation
- Support for S3, DigitalOcean Spaces, or local storage

✅ **Image Management**
- Add images to properties
- Delete images from properties
- Images stored as URLs in property `images` array

### API Endpoints

#### Upload Property Image
```
POST /v1/properties/:id/images
Authorization: Bearer <token>
Content-Type: multipart/form-data

Body:
  image: <file>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "image": {
      "url": "https://cdn.example.com/properties/1234567890-abc123.jpg",
      "size": 245678,
      "contentType": "image/jpeg"
    },
    "property": {
      "id": "property-uuid",
      "images": ["url1", "url2", "url3"]
    }
  },
  "message": "Image uploaded successfully"
}
```

#### Delete Property Image
```
DELETE /v1/properties/:id/images/:imageIndex
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "message": "Image deleted successfully",
  "data": {
    "property": {
      "id": "property-uuid",
      "images": ["url1", "url2"]
    }
  }
}
```

### File Storage Configuration

The system supports multiple storage backends:

**Environment Variables:**
```bash
STORAGE_TYPE=local|s3|spaces  # Storage backend type
STORAGE_BUCKET=juax-properties  # Bucket name
STORAGE_REGION=us-east-1  # AWS region
STORAGE_ENDPOINT=https://nyc3.digitaloceanspaces.com  # For Spaces
STORAGE_ACCESS_KEY=your-access-key
STORAGE_SECRET_KEY=your-secret-key
STORAGE_CDN_URL=https://cdn.example.com  # Optional CDN URL
```

**Storage Options:**
1. **Local Storage** (Development)
   - Files stored in `uploads/` directory
   - URLs: `/uploads/properties/filename.jpg`

2. **AWS S3** (Production)
   - Scalable cloud storage
   - CDN integration possible

3. **DigitalOcean Spaces** (Recommended for cost)
   - S3-compatible
   - Lower cost than AWS
   - Built-in CDN

### Files Created

- `src/services/fileStorageService.ts` - File storage abstraction
- `src/controllers/propertyImageController.ts` - Image upload/delete handlers
- Updated `src/routes/propertyRoutes.ts` - Added image routes

---

## 📍 Service Locations / Pickup Stations

### Features Implemented

✅ **Service Location Database**
- Store pickup/dropoff stations
- Support for pickup, dropoff, or both
- Operating hours tracking
- Location-based search

✅ **Nearby Location Search**
- Find nearby stations by coordinates
- Distance calculation (Haversine formula)
- Filter by type (pickup/dropoff/both)
- Radius-based search (default 10km)

✅ **Laundry Order Integration**
- Use service locations when users don't select custom pickup locations
- Automatic location assignment
- Validation of service location availability

### Database Schema

**Table: `service_locations`**
```sql
- id (UUID)
- name (VARCHAR)
- type (pickup|dropoff|both)
- location_latitude (DECIMAL)
- location_longitude (DECIMAL)
- address (VARCHAR)
- area_label (VARCHAR)
- city (VARCHAR) - Default: 'Kisumu'
- is_active (BOOLEAN)
- operating_hours (JSONB)
- contact_phone (VARCHAR)
- notes (TEXT)
- created_at, updated_at
```

**Sample Data:**
- Milimani Pickup Station
- Town Centre Drop-off Point
- Nyalenda Service Station
- Kibos Road Pickup Point

### API Endpoints

#### Get Nearby Service Locations (Public)
```
GET /v1/service-locations/nearby?latitude=-0.0917&longitude=34.7680&radius_km=10&type=pickup&limit=10
```

**Response:**
```json
{
  "success": true,
  "data": {
    "locations": [
      {
        "id": "location-uuid",
        "name": "Milimani Pickup Station",
        "type": "both",
        "location": {
          "latitude": -0.0917,
          "longitude": 34.7680,
          "address": "Milimani Road, Near Milimani Shopping Centre",
          "area_label": "Milimani",
          "city": "Kisumu"
        },
        "is_active": true,
        "distance_km": 2.5,
        "contact_phone": "+254712345678"
      }
    ],
    "count": 1
  }
}
```

#### List All Service Locations (Public)
```
GET /v1/service-locations?type=pickup&city=Kisumu&is_active=true
```

#### Get Service Location by ID (Public)
```
GET /v1/service-locations/:id
```

#### Create Service Location (Admin Only)
```
POST /v1/service-locations
Authorization: Bearer <admin-token>

Body:
{
  "name": "New Pickup Station",
  "type": "pickup",
  "location_latitude": -0.0917,
  "location_longitude": 34.7680,
  "address": "123 Main Street",
  "area_label": "Milimani",
  "city": "Kisumu",
  "contact_phone": "+254712345678",
  "operating_hours": {
    "monday": {"open": "08:00", "close": "18:00"},
    "tuesday": {"open": "08:00", "close": "18:00"}
  }
}
```

#### Update Service Location (Admin Only)
```
PATCH /v1/service-locations/:id
Authorization: Bearer <admin-token>
```

#### Delete Service Location (Admin Only)
```
DELETE /v1/service-locations/:id
Authorization: Bearer <admin-token>
```

### Laundry Order Integration

**Updated Laundry Order Details:**
```typescript
interface LaundryDetails {
  serviceType: string;
  quantity?: number;
  items?: string[];
  serviceLocationId?: string;  // Use this station
  pickupLocation?: Location;   // OR custom pickup
  dropoffLocation?: Location;  // OR custom dropoff
}
```

**Order Creation Logic:**
1. If `serviceLocationId` provided → Use that station's location
2. Else if `pickupLocation` provided → Use custom pickup location
3. Else if `dropoffLocation` provided → Use custom dropoff location
4. Otherwise → Use main order location

**Example Laundry Order with Service Location:**
```json
{
  "type": "laundry",
  "location": {
    "latitude": -0.0917,
    "longitude": 34.7680,
    "label": "User's location"
  },
  "details": {
    "serviceType": "washAndFold",
    "quantity": 5,
    "serviceLocationId": "station-uuid"  // Will use station location
  }
}
```

### Files Created

- `migrations/008_create_service_locations_table.sql` - Database migration
- `src/models/ServiceLocation.ts` - Type definitions
- `src/services/serviceLocationService.ts` - Business logic
- `src/controllers/serviceLocationController.ts` - Request handlers
- `src/routes/serviceLocationRoutes.ts` - API routes
- `src/validators/serviceLocationValidator.ts` - Input validation
- Updated `src/models/Order.ts` - Added service location fields
- Updated `src/services/orderService.ts` - Service location handling
- Updated `src/validators/orderValidator.ts` - Laundry validation

---

## 🚀 Usage Examples

### 1. Upload Property Image

```bash
curl -X POST http://localhost:3000/v1/properties/{property-id}/images \
  -H "Authorization: Bearer {token}" \
  -F "image=@/path/to/image.jpg"
```

### 2. Find Nearby Pickup Stations

```bash
curl "http://localhost:3000/v1/service-locations/nearby?latitude=-0.0917&longitude=34.7680&type=pickup&radius_km=5"
```

### 3. Create Laundry Order with Service Location

```bash
curl -X POST http://localhost:3000/v1/orders \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "laundry",
    "location": {
      "latitude": -0.0917,
      "longitude": 34.7680,
      "label": "Current Location"
    },
    "details": {
      "serviceType": "washAndFold",
      "quantity": 5,
      "serviceLocationId": "station-uuid"
    }
  }'
```

---

## 📋 Next Steps

### To Use These Features:

1. **Run Migration:**
   ```bash
   npm run migrate
   ```
   This will create the `service_locations` table with sample data.

2. **Configure File Storage:**
   - For development: Use `STORAGE_TYPE=local` (default)
   - For production: Configure S3 or Spaces credentials

3. **Set Up Static File Serving (Local Storage):**
   ```typescript
   // In src/index.ts (for local storage)
   import express from 'express';
   app.use('/uploads', express.static('uploads'));
   ```

4. **Test Endpoints:**
   - Upload a property image
   - Search for nearby service locations
   - Create a laundry order with service location

---

## 🔒 Security Considerations

1. **Image Upload:**
   - File type validation (JPEG, PNG, WebP only)
   - File size limits (5MB max)
   - Agent/Admin authorization required

2. **Service Locations:**
   - Public read access (for users to find stations)
   - Admin-only write access (create/update/delete)
   - Input validation and sanitization

3. **File Storage:**
   - Use environment variables for credentials
   - Never commit storage keys to Git
   - Use CDN for production (better performance + security)

---

## 📊 Database Migration

The migration includes:
- `service_locations` table creation
- Indexes for efficient queries
- Sample data for Kisumu area
- Triggers for `updated_at` timestamp

**To run:**
```bash
npm run migrate
```

---

## ✅ Status

All features are implemented and ready for use:
- ✅ Property image upload/delete
- ✅ Service locations CRUD
- ✅ Nearby location search
- ✅ Laundry order integration
- ✅ File storage abstraction (S3/Spaces/local)
- ✅ Input validation
- ✅ Authorization checks

---

*Last Updated: 2024*
