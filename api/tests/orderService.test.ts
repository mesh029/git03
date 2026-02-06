import { OrderService } from '../src/services/orderService';
import { OrderType, OrderStatus } from '../src/models/Order';
import pool from '../src/config/database';

jest.mock('../src/config/database');

describe('OrderService', () => {
  let orderService: OrderService;
  let mockPool: jest.Mocked<typeof pool>;

  beforeEach(() => {
    orderService = new OrderService();
    mockPool = pool as jest.Mocked<typeof pool>;
    jest.clearAllMocks();
  });

  describe('createOrder', () => {
    const userId = 'user-123';
    const validOrder = {
      type: OrderType.CLEANING,
      location: {
        latitude: -0.0917,
        longitude: 34.7680,
        label: 'Milimani Road, Kisumu',
      },
      details: {
        service: 'deepCleaning',
        rooms: 3,
      },
    };

    it('should create cleaning order successfully', async () => {
      const mockClient = {
        query: jest.fn(),
        release: jest.fn(),
      };

      mockPool.connect.mockResolvedValue(mockClient as any);
      mockClient.query
        .mockResolvedValueOnce({}) // BEGIN
        .mockResolvedValueOnce({
          rows: [{
            id: 'order-123',
            owner_id: userId,
            type: OrderType.CLEANING,
            status: OrderStatus.PENDING,
            location_latitude: -0.0917,
            location_longitude: 34.7680,
            location_label: 'Milimani Road, Kisumu',
            details: { service: 'deepCleaning', rooms: 3 },
            created_at: new Date(),
            updated_at: new Date(),
            cancelled_at: null,
          }],
        })
        .mockResolvedValueOnce({}); // COMMIT

      const result = await orderService.createOrder(validOrder, userId);

      expect(result.id).toBe('order-123');
      expect(result.type).toBe(OrderType.CLEANING);
      expect(mockClient.query).toHaveBeenCalledTimes(3);
      expect(mockClient.release).toHaveBeenCalled();
    });

    it('should validate location coordinates', async () => {
      const invalidOrder = {
        ...validOrder,
        location: {
          latitude: 100, // Invalid
          longitude: 34.7680,
          label: 'Test',
        },
      };

      await expect(
        orderService.createOrder(invalidOrder, userId)
      ).rejects.toThrow('Latitude must be between -90 and 90');
    });

    it('should validate property booking and check conflicts', async () => {
      const propertyBooking = {
        type: OrderType.PROPERTY_BOOKING,
        location: {
          latitude: -0.0917,
          longitude: 34.7680,
          label: 'Property Location',
        },
        details: {
          propertyId: 'property-123',
          checkIn: new Date(Date.now() + 86400000).toISOString(), // Tomorrow
          checkOut: new Date(Date.now() + 172800000).toISOString(), // Day after
          guests: 2,
        },
      };

      const mockClient = {
        query: jest.fn(),
        release: jest.fn(),
      };

      mockPool.connect.mockResolvedValue(mockClient as any);
      mockPool.query
        .mockResolvedValueOnce({
          rows: [{ id: 'property-123', is_available: true }],
        })
        .mockResolvedValueOnce({ rows: [] }); // No conflicts

      mockClient.query
        .mockResolvedValueOnce({}) // BEGIN
        .mockResolvedValueOnce({
          rows: [{
            id: 'order-123',
            owner_id: userId,
            type: OrderType.PROPERTY_BOOKING,
            status: OrderStatus.PENDING,
            location_latitude: -0.0917,
            location_longitude: 34.7680,
            location_label: 'Property Location',
            details: propertyBooking.details,
            created_at: new Date(),
            updated_at: new Date(),
            cancelled_at: null,
          }],
        })
        .mockResolvedValueOnce({}) // Insert booking
        .mockResolvedValueOnce({}); // COMMIT

      const result = await orderService.createOrder(propertyBooking, userId);

      expect(result.type).toBe(OrderType.PROPERTY_BOOKING);
    });
  });

  describe('getUserOrders', () => {
    const userId = 'user-123';

    it('should get user orders with pagination', async () => {
      mockPool.query
        .mockResolvedValueOnce({
          rows: [{ total: '5' }],
        })
        .mockResolvedValueOnce({
          rows: [
            {
              id: 'order-1',
              owner_id: userId,
              type: OrderType.CLEANING,
              status: OrderStatus.PENDING,
              location_latitude: -0.0917,
              location_longitude: 34.7680,
              location_label: 'Test',
              details: {},
              created_at: new Date(),
              updated_at: new Date(),
              cancelled_at: null,
            },
          ],
        });

      const result = await orderService.getUserOrders(userId, { limit: 20, offset: 0 });

      expect(result.orders).toHaveLength(1);
      expect(result.total).toBe(5);
      expect(result.limit).toBe(20);
    });

    it('should filter by status', async () => {
      mockPool.query
        .mockResolvedValueOnce({
          rows: [{ total: '2' }],
        })
        .mockResolvedValueOnce({
          rows: [],
        });

      await orderService.getUserOrders(userId, { status: OrderStatus.CANCELLED });

      expect(mockPool.query).toHaveBeenCalledWith(
        expect.stringContaining('status'),
        expect.arrayContaining([userId, OrderStatus.CANCELLED])
      );
    });
  });

  describe('cancelOrder', () => {
    const userId = 'user-123';
    const orderId = 'order-123';

    it('should cancel pending order', async () => {
      const mockClient = {
        query: jest.fn(),
        release: jest.fn(),
      };

      mockPool.connect.mockResolvedValue(mockClient as any);
      mockClient.query
        .mockResolvedValueOnce({}) // BEGIN
        .mockResolvedValueOnce({
          rows: [{
            id: orderId,
            owner_id: userId,
            type: OrderType.CLEANING,
            status: OrderStatus.PENDING,
            location_latitude: -0.0917,
            location_longitude: 34.7680,
            location_label: 'Test',
            details: {},
            created_at: new Date(),
            updated_at: new Date(),
            cancelled_at: null,
          }],
        })
        .mockResolvedValueOnce({
          rows: [{
            id: orderId,
            owner_id: userId,
            type: OrderType.CLEANING,
            status: OrderStatus.CANCELLED,
            location_latitude: -0.0917,
            location_longitude: 34.7680,
            location_label: 'Test',
            details: {},
            created_at: new Date(),
            updated_at: new Date(),
            cancelled_at: new Date(),
          }],
        })
        .mockResolvedValueOnce({}); // COMMIT

      const result = await orderService.cancelOrder(orderId, userId);

      expect(result.status).toBe(OrderStatus.CANCELLED);
      expect(result.cancelled_at).toBeDefined();
    });

    it('should be idempotent for already cancelled orders', async () => {
      const mockClient = {
        query: jest.fn(),
        release: jest.fn(),
      };

      mockPool.connect.mockResolvedValue(mockClient as any);
      mockClient.query
        .mockResolvedValueOnce({}) // BEGIN
        .mockResolvedValueOnce({
          rows: [{
            id: orderId,
            owner_id: userId,
            type: OrderType.CLEANING,
            status: OrderStatus.CANCELLED,
            location_latitude: -0.0917,
            location_longitude: 34.7680,
            location_label: 'Test',
            details: {},
            created_at: new Date(),
            updated_at: new Date(),
            cancelled_at: new Date(),
          }],
        })
        .mockResolvedValueOnce({}); // COMMIT

      const result = await orderService.cancelOrder(orderId, userId);

      expect(result.status).toBe(OrderStatus.CANCELLED);
      // Should not update again
      expect(mockClient.query).toHaveBeenCalledTimes(3);
    });
  });
});
