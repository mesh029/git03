# Property Image Authorization - Best Practices Implementation

## Overview

Refactored property image upload/delete functionality to follow best coding practices with proper authorization, separation of concerns, and clean code structure.

---

## 🔒 Authorization Strategy

### Two-Layer Authorization

1. **Route-Level Authorization** (Middleware Chain)
   - `authorizeAgentOrAdmin` - Ensures user is agent OR admin
   - `authorizePropertyAccess` - Ensures user owns property OR is admin

2. **Controller-Level Validation**
   - File validation
   - Image limit checks
   - Business logic validation

### Authorization Rules

✅ **Agents (Property Owners)**
- Can upload/delete images to their own properties only
- Cannot modify other agents' properties

✅ **Admins**
- Can upload/delete images to any property
- Full access for moderation purposes

❌ **Regular Users**
- Cannot upload/delete property images
- Can only view images (public access)

---

## 📁 Code Structure Improvements

### 1. Dedicated Authorization Middleware

**File:** `src/middleware/propertyAuthorization.ts`

```typescript
export const authorizePropertyAccess = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  // Checks:
  // 1. User is authenticated
  // 2. Property exists
  // 3. User is property owner (agent) OR admin
}
```

**Benefits:**
- ✅ Reusable across property-related endpoints
- ✅ Single responsibility (authorization only)
- ✅ Consistent error responses
- ✅ Easy to test

### 2. Improved Controller Structure

**File:** `src/controllers/propertyImageController.ts`

**Improvements:**
- ✅ **Private helper methods** for validation
- ✅ **Clear separation** of concerns
- ✅ **Better error handling** with proper error types
- ✅ **Image limit validation** (max 20 images)
- ✅ **File type validation** (JPEG, PNG, WebP only)
- ✅ **Cleaner code** with extracted logic

**Helper Methods:**
```typescript
private validateImageFile(file) // Validates file exists and type
private getPropertyForImageOperation(id) // Gets property + validates limits
```

### 3. Route Configuration

**File:** `src/routes/propertyRoutes.ts`

```typescript
router.post(
  '/:id/images',
  authorizeAgentOrAdmin,      // Layer 1: Must be agent/admin
  authorizePropertyAccess,     // Layer 2: Must own property OR be admin
  uploadPropertyImage,         // File upload middleware
  propertyImageController.uploadImage
);
```

**Benefits:**
- ✅ Clear authorization chain
- ✅ Early rejection (fail fast)
- ✅ Easy to understand flow

---

## 🎯 Best Practices Implemented

### 1. **Separation of Concerns**
- Authorization logic → Middleware
- Business logic → Controller
- Data access → Service layer

### 2. **DRY Principle**
- Reusable authorization middleware
- Helper methods for common operations
- Consistent error handling

### 3. **Security**
- ✅ Two-layer authorization check
- ✅ File type validation
- ✅ File size limits
- ✅ Image count limits
- ✅ Property ownership verification

### 4. **Error Handling**
- ✅ Proper error types (ValidationError, NotFoundError)
- ✅ Consistent error response format
- ✅ Clear error messages
- ✅ Graceful degradation (storage deletion failures don't break request)

### 5. **Code Quality**
- ✅ TypeScript types throughout
- ✅ JSDoc comments
- ✅ Private methods for internal logic
- ✅ Clear method names
- ✅ Single responsibility per method

### 6. **Validation**
- ✅ File existence check
- ✅ File type validation (MIME types)
- ✅ Image limit validation (max 20)
- ✅ Index validation for deletion
- ✅ Property existence check

---

## 📋 API Endpoints

### Upload Property Image
```
POST /v1/properties/:id/images
Authorization: Bearer <agent-token> OR <admin-token>
Content-Type: multipart/form-data

Body:
  image: <file> (JPEG, PNG, WebP, max 5MB)

Authorization Requirements:
  - User must be agent (property owner) OR admin
  - Property must exist
  - Property must have < 20 images
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
      "images": ["url1", "url2", "url3"],
      "imageCount": 3
    }
  },
  "message": "Image uploaded successfully"
}
```

### Delete Property Image
```
DELETE /v1/properties/:id/images/:imageIndex
Authorization: Bearer <agent-token> OR <admin-token>

Authorization Requirements:
  - User must be agent (property owner) OR admin
  - Property must exist
  - Image index must be valid
```

**Response:**
```json
{
  "success": true,
  "message": "Image deleted successfully",
  "data": {
    "property": {
      "id": "property-uuid",
      "images": ["url1", "url2"],
      "imageCount": 2
    }
  }
}
```

---

## 🔍 Authorization Flow

```
Request → authenticate (JWT check)
       → authorizeAgentOrAdmin (Role check)
       → authorizePropertyAccess (Ownership check)
       → uploadPropertyImage (File upload)
       → Controller (Business logic)
```

**Example Scenarios:**

1. **Agent uploading to own property** ✅
   - Passes `authorizeAgentOrAdmin` (is agent)
   - Passes `authorizePropertyAccess` (is owner)
   - Upload succeeds

2. **Agent uploading to other's property** ❌
   - Passes `authorizeAgentOrAdmin` (is agent)
   - Fails `authorizePropertyAccess` (not owner)
   - Returns 403 Forbidden

3. **Admin uploading to any property** ✅
   - Passes `authorizeAgentOrAdmin` (is admin)
   - Passes `authorizePropertyAccess` (is admin)
   - Upload succeeds

4. **Regular user attempting upload** ❌
   - Fails `authorizeAgentOrAdmin` (not agent/admin)
   - Returns 403 Forbidden

---

## 🛡️ Security Features

1. **File Validation**
   - MIME type checking (not just extension)
   - File size limits (5MB)
   - Image count limits (20 per property)

2. **Authorization**
   - JWT authentication required
   - Role-based access (agent/admin)
   - Resource-level authorization (ownership)

3. **Error Handling**
   - No information leakage in errors
   - Consistent error format
   - Proper HTTP status codes

4. **Storage Security**
   - File keys are generated (no user input)
   - Storage credentials in environment variables
   - CDN support for production

---

## 📊 Validation Rules

| Rule | Value | Error Message |
|------|-------|---------------|
| Max file size | 5MB | "File size must be less than 5MB" |
| Allowed types | JPEG, PNG, WebP | "Invalid file type. Only JPEG, PNG, and WebP images are allowed" |
| Max images per property | 20 | "Maximum 20 images allowed per property" |
| Image index | 0 to (count-1) | "Image not found at specified index" |

---

## ✅ Code Quality Checklist

- [x] Authorization middleware separated
- [x] Controller methods are focused and clean
- [x] Helper methods for reusable logic
- [x] Proper error types and messages
- [x] TypeScript types throughout
- [x] JSDoc comments for documentation
- [x] Consistent error response format
- [x] Input validation at multiple layers
- [x] Security best practices
- [x] Graceful error handling

---

## 🚀 Usage Example

```bash
# Agent uploading image to their property
curl -X POST http://localhost:3000/v1/properties/{property-id}/images \
  -H "Authorization: Bearer {agent-token}" \
  -F "image=@/path/to/image.jpg"

# Admin uploading image to any property
curl -X POST http://localhost:3000/v1/properties/{property-id}/images \
  -H "Authorization: Bearer {admin-token}" \
  -F "image=@/path/to/image.jpg"

# Agent trying to upload to other's property (will fail)
curl -X POST http://localhost:3000/v1/properties/{other-property-id}/images \
  -H "Authorization: Bearer {agent-token}" \
  -F "image=@/path/to/image.jpg"
# Response: 403 Forbidden - "You can only manage your own properties"
```

---

## 📝 Files Modified

1. **Created:**
   - `src/middleware/propertyAuthorization.ts` - Authorization middleware

2. **Updated:**
   - `src/controllers/propertyImageController.ts` - Refactored with best practices
   - `src/routes/propertyRoutes.ts` - Added authorization middleware chain

---

## 🎓 Key Takeaways

1. **Authorization should be in middleware** - Keeps controllers clean
2. **Two-layer checks** - Role check + Resource ownership check
3. **Fail fast** - Reject unauthorized requests early
4. **Clear error messages** - Help developers understand failures
5. **Separation of concerns** - Each layer has a single responsibility
6. **Reusable code** - Middleware can be used across endpoints

---

*Last Updated: 2024*
*Follows: REST API best practices, security best practices, clean code principles*
