import { AuthService } from '../src/services/authService';
import pool from '../src/config/database';
import redisClient from '../src/config/redis';
import { CreateUserInput } from '../src/models/User';

// Mock dependencies
jest.mock('../src/config/database');
jest.mock('../src/config/redis');

describe('AuthService', () => {
  let authService: AuthService;
  let mockPool: jest.Mocked<typeof pool>;
  let mockRedis: jest.Mocked<typeof redisClient>;

  beforeEach(() => {
    authService = new AuthService();
    mockPool = pool as jest.Mocked<typeof pool>;
    mockRedis = redisClient as jest.Mocked<typeof redisClient>;
    jest.clearAllMocks();
  });

  describe('register', () => {
    const validInput: CreateUserInput = {
      email: 'test@example.com',
      password: 'Test1234',
      name: 'Test User',
    };

    it('should register a new user successfully', async () => {
      // Mock database queries
      mockPool.query
        .mockResolvedValueOnce({ rows: [] }) // Check existing user
        .mockResolvedValueOnce({
          rows: [{
            id: 'user-123',
            email: 'test@example.com',
            name: 'Test User',
            phone: null,
            is_admin: false,
            is_agent: false,
            created_at: new Date(),
            updated_at: new Date(),
          }],
        });

      mockRedis.setEx.mockResolvedValue('OK');

      const result = await authService.register(validInput);

      expect(result.user.email).toBe('test@example.com');
      expect(result.tokens.accessToken).toBeDefined();
      expect(result.tokens.refreshToken).toBeDefined();
      expect(mockPool.query).toHaveBeenCalledTimes(2);
      expect(mockRedis.setEx).toHaveBeenCalled();
    });

    it('should throw error for invalid email format', async () => {
      const invalidInput = { ...validInput, email: 'invalid-email' };

      await expect(authService.register(invalidInput)).rejects.toThrow('Invalid email format');
    });

    it('should throw error for weak password', async () => {
      const weakPasswordInput = { ...validInput, password: 'weak' };

      await expect(authService.register(weakPasswordInput)).rejects.toThrow();
    });

    it('should throw error for existing email', async () => {
      mockPool.query.mockResolvedValueOnce({
        rows: [{ id: 'existing-user' }],
      });

      await expect(authService.register(validInput)).rejects.toThrow('Email already registered');
    });
  });

  describe('login', () => {
    const email = 'test@example.com';
    const password = 'Test1234';
    const hashedPassword = '$2b$12$hashedpassword';

    it('should login user successfully', async () => {
      mockPool.query.mockResolvedValueOnce({
        rows: [{
          id: 'user-123',
          email: 'test@example.com',
          password_hash: hashedPassword,
          name: 'Test User',
          phone: null,
          is_admin: false,
          is_agent: false,
          created_at: new Date(),
          updated_at: new Date(),
        }],
      });

      // Mock bcrypt compare
      const bcrypt = require('bcrypt');
      jest.spyOn(bcrypt, 'compare').mockResolvedValue(true);

      mockRedis.setEx.mockResolvedValue('OK');

      const result = await authService.login(email, password);

      expect(result.user.email).toBe(email);
      expect(result.tokens.accessToken).toBeDefined();
      expect(result.tokens.refreshToken).toBeDefined();
    });

    it('should throw error for non-existent user', async () => {
      mockPool.query.mockResolvedValueOnce({ rows: [] });

      await expect(authService.login(email, password)).rejects.toThrow('Invalid email or password');
    });

    it('should throw error for incorrect password', async () => {
      mockPool.query.mockResolvedValueOnce({
        rows: [{
          id: 'user-123',
          email: 'test@example.com',
          password_hash: hashedPassword,
          name: 'Test User',
          phone: null,
          is_admin: false,
          is_agent: false,
          created_at: new Date(),
          updated_at: new Date(),
        }],
      });

      const bcrypt = require('bcrypt');
      jest.spyOn(bcrypt, 'compare').mockResolvedValue(false);

      await expect(authService.login(email, password)).rejects.toThrow('Invalid email or password');
    });
  });

  describe('refreshToken', () => {
    it('should refresh tokens successfully', async () => {
      const refreshToken = 'valid-refresh-token';
      const decoded = {
        sub: 'user-123',
        email: 'test@example.com',
        iat: Math.floor(Date.now() / 1000),
        exp: Math.floor(Date.now() / 1000) + 3600,
      };

      mockRedis.get.mockResolvedValue(refreshToken);
      mockPool.query.mockResolvedValueOnce({
        rows: [{
          id: 'user-123',
          email: 'test@example.com',
        }],
      });
      mockRedis.setEx.mockResolvedValue('OK');

      // Mock jwt.verify
      const jwt = require('jsonwebtoken');
      jest.spyOn(jwt, 'verify').mockReturnValue(decoded);

      const result = await authService.refreshToken(refreshToken);

      expect(result.accessToken).toBeDefined();
      expect(result.refreshToken).toBeDefined();
    });
  });

  describe('logout', () => {
    it('should remove refresh token', async () => {
      mockRedis.del.mockResolvedValue(1);

      await authService.logout('user-123');

      expect(mockRedis.del).toHaveBeenCalledWith('refresh_token:user-123');
    });
  });
});
