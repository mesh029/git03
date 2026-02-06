import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import pool from '../config/database';
import redisClient from '../config/redis';
import { config } from '../config/env';
import { User, CreateUserInput, UserResponse } from '../models/User';
import { AuthenticationError, ValidationError, NotFoundError } from '../utils/errors';
import { logInfo, logError, logWarn, logDebug } from '../utils/logger';

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
    } as jwt.SignOptions);
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
    } as jwt.SignOptions);
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
    logDebug('Registration attempt', { email: input.email.toLowerCase() });

    // Validate email format
    if (!this.validateEmail(input.email)) {
      logWarn('Registration failed: invalid email format', { email: input.email });
      throw new ValidationError('Invalid email format');
    }

    // Validate password strength
    const passwordValidation = this.validatePassword(input.password);
    if (!passwordValidation.valid) {
      logWarn('Registration failed: weak password', { 
        email: input.email.toLowerCase(),
        reason: passwordValidation.message 
      });
      throw new ValidationError(passwordValidation.message || 'Invalid password');
    }

    // Check if email already exists
    const existingUser = await pool.query(
      'SELECT id FROM users WHERE email = $1',
      [input.email.toLowerCase()]
    );

    if (existingUser.rows.length > 0) {
      logWarn('Registration failed: email already exists', { email: input.email.toLowerCase() });
      throw new ValidationError('Email already registered');
    }

    try {
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

      logInfo('User registered successfully', {
        userId: user.id,
        email: user.email,
        name: user.name,
        isAdmin: user.is_admin,
        isAgent: user.is_agent,
      });

      return {
        user: this.toUserResponse(user),
        tokens: {
          accessToken,
          refreshToken,
        },
      };
    } catch (error) {
      logError(error as Error, {
        context: 'user_registration',
        email: input.email.toLowerCase(),
      });
      throw error;
    }
  }

  /**
   * Login user
   */
  async login(email: string, password: string): Promise<LoginResponse> {
    logDebug('Login attempt', { email: email.toLowerCase() });

    try {
      // Find user by email
      const result = await pool.query(
        'SELECT id, email, password_hash, name, phone, is_admin, is_agent, created_at, updated_at FROM users WHERE email = $1',
        [email.toLowerCase()]
      );

      if (result.rows.length === 0) {
        logWarn('Login failed: user not found', { email: email.toLowerCase() });
        throw new AuthenticationError('Invalid email or password');
      }

      const user = result.rows[0] as User;

      // Verify password
      const passwordValid = await this.comparePassword(password, user.password_hash);
      if (!passwordValid) {
        logWarn('Login failed: invalid password', { 
          userId: user.id,
          email: user.email 
        });
        throw new AuthenticationError('Invalid email or password');
      }

      // Generate tokens
      const accessToken = this.generateAccessToken(user.id, user.email);
      const refreshToken = this.generateRefreshToken(user.id, user.email);

      // Store refresh token
      await this.storeRefreshToken(user.id, refreshToken);

      logInfo('User logged in successfully', {
        userId: user.id,
        email: user.email,
        isAdmin: user.is_admin,
        isAgent: user.is_agent,
      });

      return {
        user: this.toUserResponse(user),
        tokens: {
          accessToken,
          refreshToken,
        },
      };
    } catch (error) {
      if (error instanceof AuthenticationError) {
        throw error;
      }
      logError(error as Error, {
        context: 'user_login',
        email: email.toLowerCase(),
      });
      throw error;
    }
  }

  /**
   * Refresh access token
   */
  async refreshToken(refreshToken: string): Promise<AuthTokens> {
    logDebug('Token refresh attempt');

    try {
      // Verify refresh token
      const decoded = jwt.verify(refreshToken, config.jwt.secret) as TokenPayload;

      // Validate token exists in Redis
      const isValid = await this.validateRefreshToken(decoded.sub, refreshToken);
      if (!isValid) {
        logWarn('Token refresh failed: invalid refresh token', { userId: decoded.sub });
        throw new AuthenticationError('Invalid refresh token');
      }

      // Get user from database
      const result = await pool.query(
        'SELECT id, email FROM users WHERE id = $1',
        [decoded.sub]
      );

      if (result.rows.length === 0) {
        logWarn('Token refresh failed: user not found', { userId: decoded.sub });
        throw new NotFoundError('User');
      }

      const user = result.rows[0];

      // Generate new tokens
      const newAccessToken = this.generateAccessToken(user.id, user.email);
      const newRefreshToken = this.generateRefreshToken(user.id, user.email);

      // Store new refresh token
      await this.storeRefreshToken(user.id, newRefreshToken);

      logInfo('Token refreshed successfully', {
        userId: user.id,
        email: user.email,
      });

      return {
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      };
    } catch (error) {
      if (error instanceof jwt.JsonWebTokenError) {
        logWarn('Token refresh failed: JWT error', { 
          error: error.message 
        });
        throw new AuthenticationError('Invalid refresh token');
      }
      if (error instanceof AuthenticationError || error instanceof NotFoundError) {
        throw error;
      }
      logError(error as Error, {
        context: 'token_refresh',
      });
      throw error;
    }
  }

  /**
   * Logout user (remove refresh token)
   */
  async logout(userId: string): Promise<void> {
    try {
      await this.removeRefreshToken(userId);
      logInfo('User logged out successfully', { userId });
    } catch (error) {
      logError(error as Error, {
        context: 'user_logout',
        userId,
      });
      throw error;
    }
  }

  /**
   * Get user by ID
   */
  async getUserById(userId: string): Promise<UserResponse> {
    try {
      const result = await pool.query(
        'SELECT id, email, name, phone, is_admin, is_agent, created_at, updated_at FROM users WHERE id = $1',
        [userId]
      );

      if (result.rows.length === 0) {
        logWarn('User not found', { userId });
        throw new NotFoundError('User');
      }

      return result.rows[0] as UserResponse;
    } catch (error) {
      if (error instanceof NotFoundError) {
        throw error;
      }
      logError(error as Error, {
        context: 'get_user_by_id',
        userId,
      });
      throw error;
    }
  }

  /**
   * Verify JWT token and return payload
   */
  verifyToken(token: string): TokenPayload {
    try {
      const payload = jwt.verify(token, config.jwt.secret) as TokenPayload;
      logDebug('Token verified successfully', { userId: payload.sub });
      return payload;
    } catch (error) {
      if (error instanceof jwt.TokenExpiredError) {
        logWarn('Token verification failed: token expired');
        throw new AuthenticationError('Token expired');
      }
      if (error instanceof jwt.JsonWebTokenError) {
        logWarn('Token verification failed: invalid token', { 
          error: error.message 
        });
        throw new AuthenticationError('Invalid token');
      }
      logError(error as Error, {
        context: 'token_verification',
      });
      throw error;
    }
  }
}

export const authService = new AuthService();
