import { S3Client, PutObjectCommand, DeleteObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { ValidationError } from '../utils/errors';
import crypto from 'crypto';
import path from 'path';

// File storage configuration
const STORAGE_TYPE = process.env.STORAGE_TYPE || 'local'; // 'local', 's3', 'spaces'
const STORAGE_BUCKET = process.env.STORAGE_BUCKET || 'juax-properties';
const STORAGE_REGION = process.env.STORAGE_REGION || 'us-east-1';
const STORAGE_ENDPOINT = process.env.STORAGE_ENDPOINT; // For DigitalOcean Spaces
const STORAGE_ACCESS_KEY = process.env.STORAGE_ACCESS_KEY || '';
const STORAGE_SECRET_KEY = process.env.STORAGE_SECRET_KEY || '';
const STORAGE_CDN_URL = process.env.STORAGE_CDN_URL || ''; // CDN URL for public access

let s3Client: S3Client | null = null;

if (STORAGE_TYPE === 's3' || STORAGE_TYPE === 'spaces') {
  s3Client = new S3Client({
    region: STORAGE_REGION,
    endpoint: STORAGE_ENDPOINT || undefined,
    credentials: {
      accessKeyId: STORAGE_ACCESS_KEY,
      secretAccessKey: STORAGE_SECRET_KEY,
    },
    forcePathStyle: STORAGE_TYPE === 'spaces', // Required for DigitalOcean Spaces
  });
}

export interface UploadFileResult {
  url: string;
  key: string;
  size: number;
  contentType: string;
}

export class FileStorageService {
  /**
   * Validate file
   */
  private validateFile(file: Express.Multer.File): void {
    const MAX_SIZE = 5 * 1024 * 1024; // 5MB
    const ALLOWED_TYPES = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];

    if (file.size > MAX_SIZE) {
      throw new ValidationError('File size must be less than 5MB');
    }

    if (!ALLOWED_TYPES.includes(file.mimetype)) {
      throw new ValidationError('File must be an image (JPEG, PNG, or WebP)');
    }
  }

  /**
   * Generate unique file key
   */
  private generateFileKey(folder: string, originalName: string): string {
    const ext = path.extname(originalName);
    const hash = crypto.randomBytes(16).toString('hex');
    const timestamp = Date.now();
    return `${folder}/${timestamp}-${hash}${ext}`;
  }

  /**
   * Upload file to storage
   */
  async uploadFile(
    file: Express.Multer.File,
    folder: string = 'properties'
  ): Promise<UploadFileResult> {
    this.validateFile(file);

    const key = this.generateFileKey(folder, file.originalname);

    if (STORAGE_TYPE === 's3' || STORAGE_TYPE === 'spaces') {
      return this.uploadToS3(file, key);
    } else {
      // Local storage (for development)
      return this.uploadToLocal(file, key);
    }
  }

  /**
   * Upload to S3-compatible storage (AWS S3 or DigitalOcean Spaces)
   */
  private async uploadToS3(
    file: Express.Multer.File,
    key: string
  ): Promise<UploadFileResult> {
    if (!s3Client) {
      throw new Error('S3 client not configured');
    }

    const command = new PutObjectCommand({
      Bucket: STORAGE_BUCKET,
      Key: key,
      Body: file.buffer,
      ContentType: file.mimetype,
      ACL: 'public-read',
    });

    await s3Client.send(command);

    // Return CDN URL if configured, otherwise construct S3 URL
    const url = STORAGE_CDN_URL
      ? `${STORAGE_CDN_URL}/${key}`
      : STORAGE_ENDPOINT
      ? `${STORAGE_ENDPOINT}/${STORAGE_BUCKET}/${key}`
      : `https://${STORAGE_BUCKET}.s3.${STORAGE_REGION}.amazonaws.com/${key}`;

    return {
      url,
      key,
      size: file.size,
      contentType: file.mimetype,
    };
  }

  /**
   * Upload to local storage (development only)
   */
  private async uploadToLocal(
    file: Express.Multer.File,
    key: string
  ): Promise<UploadFileResult> {
    const fs = await import('fs/promises');
    const uploadDir = path.join(process.cwd(), 'uploads', path.dirname(key));

    // Create directory if it doesn't exist
    await fs.mkdir(uploadDir, { recursive: true });

    const filePath = path.join(process.cwd(), 'uploads', key);
    await fs.writeFile(filePath, file.buffer);

    // Return local URL (in production, this should be served via CDN/static server)
    const url = `/uploads/${key}`;

    return {
      url,
      key,
      size: file.size,
      contentType: file.mimetype,
    };
  }

  /**
   * Delete file from storage
   */
  async deleteFile(key: string): Promise<void> {
    if (STORAGE_TYPE === 's3' || STORAGE_TYPE === 'spaces') {
      if (!s3Client) {
        throw new Error('S3 client not configured');
      }

      const command = new DeleteObjectCommand({
        Bucket: STORAGE_BUCKET,
        Key: key,
      });

      await s3Client.send(command);
    } else {
      // Local storage
      const fs = await import('fs/promises');
      const filePath = path.join(process.cwd(), 'uploads', key);
      try {
        await fs.unlink(filePath);
      } catch (error) {
        // File might not exist, ignore
      }
    }
  }

  /**
   * Get signed URL for private file access (if needed)
   */
  async getSignedUrl(key: string, expiresIn: number = 3600): Promise<string> {
    if (STORAGE_TYPE === 's3' || STORAGE_TYPE === 'spaces') {
      if (!s3Client) {
        throw new Error('S3 client not configured');
      }

      const command = new GetObjectCommand({
        Bucket: STORAGE_BUCKET,
        Key: key,
      });

      return getSignedUrl(s3Client, command, { expiresIn });
    } else {
      // For local storage, return public URL
      return `/uploads/${key}`;
    }
  }
}

export const fileStorageService = new FileStorageService();
