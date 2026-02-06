import { Request, Response, NextFunction } from 'express';
import multer from 'multer';
import { fileStorageService } from '../services/fileStorageService';
import { propertyService } from '../services/propertyService';
import pool from '../config/database';
import { ValidationError, NotFoundError } from '../utils/errors';
import { logWarn } from '../utils/logger';

// Configure multer for memory storage
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
  },
});

export const uploadPropertyImage = upload.single('image');

export class PropertyImageController {
  /**
   * Validate image file
   */
  private validateImageFile(file: Express.Multer.File | undefined): void {
    if (!file) {
      throw new ValidationError('Image file is required');
    }

    const allowedMimeTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
    if (!allowedMimeTypes.includes(file.mimetype)) {
      throw new ValidationError('Invalid file type. Only JPEG, PNG, and WebP images are allowed');
    }
  }

  /**
   * Get property and validate access (already authorized by middleware)
   */
  private async getPropertyForImageOperation(propertyId: string) {
    const property = await propertyService.getPropertyById(propertyId);
    
    // Check image limit (max 20 images per property)
    const maxImages = 20;
    if (property.images && property.images.length >= maxImages) {
      throw new ValidationError(`Maximum ${maxImages} images allowed per property`);
    }

    return property;
  }

  /**
   * Upload image for property
   * POST /v1/properties/:id/images
   * 
   * Authorization: Property owner (agent) OR Admin (handled by middleware)
   */
  async uploadImage(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      // Validate file
      this.validateImageFile(req.file);

      const { id } = req.params;

      // Get property (authorization already checked by middleware)
      const property = await this.getPropertyForImageOperation(id);

      // Upload file to storage
      const uploadResult = await fileStorageService.uploadFile(
        req.file!,
        'properties'
      );

      // Add image URL to property images array
      const currentImages = property.images || [];
      const updatedImages = [...currentImages, uploadResult.url];

      // Update property in database
      await pool.query(
        'UPDATE properties SET images = $1, updated_at = NOW() WHERE id = $2',
        [updatedImages, id]
      );

      // Fetch updated property to return
      const updatedProperty = await propertyService.getPropertyById(id);

      res.status(201).json({
        success: true,
        data: {
          image: {
            url: uploadResult.url,
            size: uploadResult.size,
            contentType: uploadResult.contentType,
          },
          property: {
            id: updatedProperty.id,
            images: updatedProperty.images,
            imageCount: updatedProperty.images?.length || 0,
          },
        },
        message: 'Image uploaded successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Delete image from property
   * DELETE /v1/properties/:id/images/:imageIndex
   * 
   * Authorization: Property owner (agent) OR Admin (handled by middleware)
   */
  async deleteImage(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { id, imageIndex } = req.params;
      const index = parseInt(imageIndex, 10);

      // Validate image index
      if (isNaN(index) || index < 0) {
        throw new ValidationError('Invalid image index');
      }

      // Get property (authorization already checked by middleware)
      const property = await propertyService.getPropertyById(id);

      // Validate image exists
      if (!property.images || property.images.length === 0) {
        throw new NotFoundError('Property has no images');
      }

      if (index >= property.images.length) {
        throw new NotFoundError('Image not found at specified index');
      }

      const imageUrl = property.images[index];
      const updatedImages = property.images.filter((_, i) => i !== index);

      // Delete file from storage (best effort - don't fail if storage deletion fails)
      // Extract storage key from URL
      // URLs can be: /uploads/properties/file.jpg or https://cdn.com/properties/file.jpg
      const urlParts = imageUrl.split('/');
      const fileName = urlParts[urlParts.length - 1];
      const folder = urlParts[urlParts.length - 2];
      const storageKey = `${folder}/${fileName}`;
      
      try {
        await fileStorageService.deleteFile(storageKey);
      } catch (error) {
        // Log but don't fail the request if storage deletion fails
        // The database update will still proceed
        logWarn('Failed to delete file from storage (continuing anyway)', {
          propertyId: id,
          storageKey,
          error: error instanceof Error ? error.message : String(error),
        });
      }

      // Update property in database
      await pool.query(
        'UPDATE properties SET images = $1, updated_at = NOW() WHERE id = $2',
        [updatedImages, id]
      );

      // Fetch updated property to return
      const updatedProperty = await propertyService.getPropertyById(id);

      res.status(200).json({
        success: true,
        message: 'Image deleted successfully',
        data: {
          property: {
            id: updatedProperty.id,
            images: updatedProperty.images,
            imageCount: updatedProperty.images?.length || 0,
          },
        },
      });
    } catch (error) {
      next(error);
    }
  }
}

export const propertyImageController = new PropertyImageController();
