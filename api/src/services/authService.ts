import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import pool from '../config/database';
import redisClient from '../config/redis';
import { config } from '../config/env';
import { User, CreateUserInput, UserResponse } from '../models/User';
import { AuthenticationError, ValidationError, NotFoundError } from '../utils/errors';

const SALT_ROUNDS = 12;

export interface TokenPayload {
  sub: string;
  email: string;
  iat?: number;
  exp?: number;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface LoginResponse {
  user: UserResponse;
  tokens: AuthTokens;
}

export class AuthService {
  /**
   * Hash password using bcrypt
   */
  private async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, SALT_ROUNDS);
  }

  /**
   * Compare password with hash
   */
  private async comparePassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }

  /**
   * Generate JWT access token
   */
  private generateAccessToken(userId: string, email: string): string {
    const payload: TokenPayload = {
      sub: userId,
      email,
    };

    return jwt.sign(payload, config.jwt.secret, {
      expiresIn: config.jwt.expiresIn,
    });
  }

  /**
   * Generate JWT refresh token
   */
  private generateRefreshToken(userId: string, email: string): string {
    const payload: TokenPayload = {
      sub: userId,
      email,
    };

    return jwt.sign(payload, config.jwt.secret, {
      expiresIn: config.jwt.refreshExpiresIn,
    });
  }

  /**
   * Store refresh token in Redis
   */
  private async storeRefreshToken(userId: string, refreshToken: string): Promise<void> {
    const key = `refresh_token:${userId}`;
    const ttl = 7 * 24 * 60 * 60; // 7 days in seconds

    await redisClient.setEx(key, ttl, refreshToken);
  }

  /**
   * Validate refresh token from Redis
   */
  private async validateRefreshToken(userId: string, refreshToken: string): Promise<boolean> {
    const key = `refresh_token:${userId}`;
    const storedToken = await redisClient.get(key);

    return storedToken === refreshToken;
  }

  /**
   * Remove refresh token from Redis
   */
  private async removeRefreshToken(userId: string): Promise<void> {
    const key = `refresh_token:${userId}`;
    await redisClient.del(key);
  }

  /**
   * Validate email format
   */
  private validateEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  /**
   * Validate password strength
   */
  private validatePassword(password: string): { valid: boolean; message?: string } {
    if (password.length < 8) {
      return { valid: false, message: 'Password must be at least 8 characters' };
    }

    if (!/[A-Z]/.test(password)) {
      return { valid: false, message: 'Password must contain at least one uppercase letter' };
    }

    if (!/[a-z]/.test(password)) {
      return { valid: false, message: 'Password must contain at least one lowercase letter' };
    }

    if (!/[0-9]/.test(password)) {
      return { valid: false, message: 'Password must contain at least one number' };
    }

    return { valid: true };
  }

  /**
   * Convert database user to response format (exclude password_hash)
   */
  private toUserResponse(user: User): UserResponse {
    const { password_hash, ...userResponse } = user;
    return userResponse;
  }

  /**
   * Register a new user
   */
  async register(input: CreateUserInput): Promise<LoginResponse> {
    // Validate email format
    if (!this.validateEmail(input.email)) {
      throw new ValidationError('Invalid email format');
    }

    // Validate password strength
    const passwordValidation = this.validatePassword(input.password);
    if (!passwordValidation.valid) {
      throw new ValidationError(passwordValidation.message || 'Invalid password');
    }

    // Check if email already exists
    const existingUser = await pool.query(
      'SELECT id FROM users WHERE email = $1',
      [input.email.toLowerCase()]
    );

    if (existingUser.rows.length > 0) {
      throw new ValidationError('Email already registered');
    }

    // Hash password
    const passwordHash = await this.hashPassword(input.password);

    // Create user
    const result = await pool.query(
      `INSERT INTO users (email, password_hash, name, phone)
       VALUES ($1, $2, $3, $4)
       RETURNING id, email, name, phone, is_admin, is_agent, created_at, updated_at`,
      [
        input.email.toLowerCase(),
        passwordHash,
        input.name,
        input.phone || null,
      ]
    );

    const user = result.rows[0] as User;

    // Generate tokens
    const accessToken = this.generateAccessToken(user.id, user.email);
    const refreshToken = this.generateRefreshToken(user.id, user.email);

    // Store refresh token
    await this.storeRefreshToken(user.id, refreshToken);

    return {
      user: this.toUserResponse(user),
      tokens: {
        accessToken,
        refreshToken,
      },
    };
  }

  /**
   * Login user
   */
  async login(email: string, password: string): Promise<LoginResponse> {
    // Find user by email
    const result = await pool.query(
      'SELECT id, email, password_hash, name, phone, is_admin, is_agent, created_at, updated_at FROM users WHERE email = $1',
      [email.toLowerCase()]
    );

    if (result.rows.length === 0) {
      throw new AuthenticationError('Invalid email or password');
    }

    const user = result.rows[0] as User;

    // Verify password
    const passwordValid = await this.comparePassword(password, user.password_hash);
    if (!passwordValid) {
      throw new AuthenticationError('Invalid email or password');
    }

    // Generate tokens
    const accessToken = this.generateAccessToken(user.id, user.email);
    const refreshToken = this.generateRefreshToken(user.id, user.email);

    // Store refresh token
    await this.storeRefreshToken(user.id, refreshToken);

    return {
      user: this.toUserResponse(user),
      tokens: {
        accessToken,
        refreshToken,
      },
    };
  }

  /**
   * Refresh access token
   */
  async refreshToken(refreshToken: string): Promise<AuthTokens> {
    try {
      // Verify refresh token
      const decoded = jwt.verify(refreshToken, config.jwt.secret) as TokenPayload;

      // Validate token exists in Redis
      const isValid = await this.validateRefreshToken(decoded.sub, refreshToken);
      if (!isValid) {
        throw new AuthenticationError('Invalid refresh token');
      }

      // Get user from database
      const result = await pool.query(
        'SELECT id, email FROM users WHERE id = $1',
        [decoded.sub]
      );

      if (result.rows.length === 0) {
        throw new NotFoundError('User');
      }

      const user = result.rows[0];

      // Generate new tokens
      const newAccessToken = this.generateAccessToken(user.id, user.email);
      const newRefreshToken = this.generateRefreshToken(user.id, user.email);

      // Store new refresh token
      await this.storeRefreshToken(user.id, newRefreshToken);

      return {
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      };
    } catch (error) {
      if (error instanceof jwt.JsonWebTokenError) {
        throw new AuthenticationError('Invalid refresh token');
      }
      throw error;
    }
  }

  /**
   * Logout user (remove refresh token)
   */
  async logout(userId: string): Promise<void> {
    await this.removeRefreshToken(userId);
  }

  /**
   * Get user by ID
   */
  async getUserById(userId: string): Promise<UserResponse> {
    const result = await pool.query(
      'SELECT id, email, name, phone, is_admin, is_agent, created_at, updated_at FROM users WHERE id = $1',
      [userId]
    );

    if (result.rows.length === 0) {
      throw new NotFoundError('User');
    }

    return result.rows[0] as UserResponse;
  }

  /**
   * Verify JWT token and return payload
   */
  verifyToken(token: string): TokenPayload {
    try {
      return jwt.verify(token, config.jwt.secret) as TokenPayload;
    } catch (error) {
      if (error instanceof jwt.TokenExpiredError) {
        throw new AuthenticationError('Token expired');
      }
      if (error instanceof jwt.JsonWebTokenError) {
        throw new AuthenticationError('Invalid token');
      }
      throw error;
    }
  }
}

export const authService = new AuthService();
