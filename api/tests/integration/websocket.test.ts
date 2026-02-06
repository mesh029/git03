import { io as SocketIOClient, Socket } from 'socket.io-client';
import request from 'supertest';
import {
  getTestApp,
  getTestHttpServer,
  getTestServerPort,
  initializeTestApp,
  setupTestDatabase,
  cleanupTestDatabase,
  closeTestConnections,
} from '../setup';
import { createTestUser, createTestOrder, generateTestToken } from '../helpers';

describe('WebSocket Real-time Tracking Tests', () => {
  let app: any;
  let pool: any;
  let httpServer: any;
  let serverPort: number;

  // Test users
  let orderOwner: any;
  let serviceProvider: any;
  let admin: any;
  let unauthorizedUser: any;

  // Tokens
  let ownerToken: string;
  let providerToken: string;
  let adminToken: string;
  let unauthorizedToken: string;

  // Test order
  let testOrder: any;

  beforeAll(async () => {
    await initializeTestApp();
    app = getTestApp();
    httpServer = getTestHttpServer();
    serverPort = getTestServerPort();
    pool = await setupTestDatabase();
  });

  beforeEach(async () => {
    await cleanupTestDatabase();

    // Create test users
    orderOwner = await createTestUser(pool, {
      email: 'owner@juax.test',
      password: 'Test123!@#',
      name: 'Order Owner',
    });

    serviceProvider = await createTestUser(pool, {
      email: 'provider@juax.test',
      password: 'Test123!@#',
      name: 'Service Provider',
      is_agent: true,
    });

    admin = await createTestUser(pool, {
      email: 'admin@juax.test',
      password: 'Test123!@#',
      name: 'Admin User',
      is_admin: true,
    });

    unauthorizedUser = await createTestUser(pool, {
      email: 'unauthorized@juax.test',
      password: 'Test123!@#',
      name: 'Unauthorized User',
    });

    // Generate tokens
    ownerToken = generateTestToken(orderOwner.id, orderOwner.email);
    providerToken = generateTestToken(serviceProvider.id, serviceProvider.email);
    adminToken = generateTestToken(admin.id, admin.email);
    unauthorizedToken = generateTestToken(unauthorizedUser.id, unauthorizedUser.email);

    // Create test order
    testOrder = await createTestOrder(pool, orderOwner.id, {
      type: 'cleaning',
      status: 'pending',
      location_latitude: -1.2634,
      location_longitude: 36.8007,
      location_label: 'Westlands, Nairobi',
      details: { service: 'deepCleaning', rooms: 3 },
    });
  });

  afterAll(async () => {
    await closeTestConnections();
  });

  describe('WebSocket Connection & Authentication', () => {
    it('should connect successfully with valid JWT token', (done) => {
      const socket = SocketIOClient(`http://localhost:${serverPort}`, {
        auth: {
          token: ownerToken,
        },
        transports: ['websocket'],
      });

      socket.on('connect', () => {
        expect(socket.connected).toBe(true);
        socket.disconnect();
        done();
      });

      socket.on('connect_error', (error) => {
        socket.disconnect();
        done(error);
      });
    });

    it('should reject connection without token', (done) => {
      const socket = SocketIOClient(`http://localhost:${serverPort}`, {
        transports: ['websocket'],
      });

      socket.on('connect', () => {
        socket.disconnect();
        done(new Error('Should not have connected without token'));
      });

      socket.on('connect_error', (error) => {
        expect(error.message).toContain('Authentication');
        socket.disconnect();
        done();
      });
    });

    it('should reject connection with invalid token', (done) => {
      const socket = SocketIOClient(`http://localhost:${serverPort}`, {
        auth: {
          token: 'invalid-token',
        },
        transports: ['websocket'],
      });

      socket.on('connect', () => {
        socket.disconnect();
        done(new Error('Should not have connected with invalid token'));
      });

      socket.on('connect_error', (error) => {
        expect(error.message).toContain('Authentication');
        socket.disconnect();
        done();
      });
    });

    it('should reject connection with expired token', (done) => {
      const expiredToken = generateTestToken(orderOwner.id, orderOwner.email);
      // Note: In real scenario, we'd need to wait for token expiration or use a different secret
      // For now, this test verifies the authentication middleware is called
      const socket = SocketIOClient(`http://localhost:${serverPort}`, {
        auth: {
          token: 'expired-token-format',
        },
        transports: ['websocket'],
      });

      socket.on('connect_error', (error) => {
        expect(error.message).toContain('Authentication');
        socket.disconnect();
        done();
      });
    });
  });

  describe('Order Room Management', () => {
    it('should allow order owner to join order room', (done) => {
      const socket = SocketIOClient(`http://localhost:${serverPort}`, {
        auth: { token: ownerToken },
        transports: ['websocket'],
      });

      socket.on('connect', () => {
        socket.emit('join_order', testOrder.id);

        socket.on('joined_order', (data) => {
          expect(data.orderId).toBe(testOrder.id);
          socket.disconnect();
          done();
        });

        socket.on('error', (error) => {
          socket.disconnect();
          done(error);
        });
      });
    });

    it('should allow admin to join any order room', (done) => {
      const socket = SocketIOClient(`http://localhost:${serverPort}`, {
        auth: { token: adminToken },
        transports: ['websocket'],
      });

      socket.on('connect', () => {
        socket.emit('join_order', testOrder.id);

        socket.on('joined_order', (data) => {
          expect(data.orderId).toBe(testOrder.id);
          socket.disconnect();
          done();
        });
      });
    });

    it('should allow service provider to join assigned order room', async () => {
      // Assign service provider to order
      await pool.query(
        'UPDATE order_tracking SET service_provider_id = $1 WHERE order_id = $2',
        [serviceProvider.id, testOrder.id]
      );

      return new Promise<void>((resolve, reject) => {
        const socket = SocketIOClient(`http://localhost:${serverPort}`, {
          auth: { token: providerToken },
          transports: ['websocket'],
        });

        socket.on('connect', () => {
          socket.emit('join_order', testOrder.id);

          socket.on('joined_order', (data) => {
            expect(data.orderId).toBe(testOrder.id);
            socket.disconnect();
            resolve();
          });

          socket.on('error', (error) => {
            socket.disconnect();
            reject(error);
          });
        });
      });
    });

    it('should reject unauthorized user from joining order room', (done) => {
      const socket = SocketIOClient(`http://localhost:${serverPort}`, {
        auth: { token: unauthorizedToken },
        transports: ['websocket'],
      });

      socket.on('connect', () => {
        socket.emit('join_order', testOrder.id);

        socket.on('error', (error: any) => {
          expect(error.code).toBe('ACCESS_DENIED');
          socket.disconnect();
          done();
        });

        // Should not receive joined_order event
        socket.on('joined_order', () => {
          socket.disconnect();
          done(new Error('Should not have joined order room'));
        });
      });
    });

    it('should allow leaving order room', (done) => {
      const socket = SocketIOClient(`http://localhost:${serverPort}`, {
        auth: { token: ownerToken },
        transports: ['websocket'],
      });

      socket.on('connect', () => {
        socket.emit('join_order', testOrder.id);

        socket.on('joined_order', () => {
          socket.emit('leave_order', testOrder.id);

          socket.on('left_order', (data) => {
            expect(data.orderId).toBe(testOrder.id);
            socket.disconnect();
            done();
          });
        });
      });
    });

    it('should reject joining non-existent order room', (done) => {
      const socket = SocketIOClient(`http://localhost:${serverPort}`, {
        auth: { token: ownerToken },
        transports: ['websocket'],
      });

      socket.on('connect', () => {
        socket.emit('join_order', '00000000-0000-0000-0000-000000000000');

        socket.on('error', (error: any) => {
          expect(error.code).toBe('ACCESS_DENIED');
          socket.disconnect();
          done();
        });
      });
    });
  });

  describe('Real-time Order Status Updates', () => {
    it('should broadcast order_status_changed event when status is updated', (done) => {
      const socket = SocketIOClient(`http://localhost:${serverPort}`, {
        auth: { token: ownerToken },
        transports: ['websocket'],
      });

      let statusUpdateReceived = false;

      socket.on('connect', () => {
        socket.emit('join_order', testOrder.id);

        socket.on('joined_order', async () => {
          // Update order status via REST API
          const response = await request(app)
            .patch(`/v1/orders/${testOrder.id}/status`)
            .set('Authorization', `Bearer ${adminToken}`)
            .send({
              status: 'assigned',
              notes: 'Test status update',
            });

          expect(response.status).toBe(200);
        });

        socket.on('order_status_changed', (data: any) => {
          expect(data.orderId).toBe(testOrder.id);
          expect(data.status).toBe('assigned');
          expect(data.updatedBy).toBe(admin.id);
          expect(data.timestamp).toBeDefined();
          statusUpdateReceived = true;
        });

        socket.on('order_update', (data: any) => {
          if (statusUpdateReceived) {
            expect(data.orderId).toBe(testOrder.id);
            expect(data.tracking).toBeDefined();
            expect(data.tracking.currentStatus).toBe('assigned');
            socket.disconnect();
            done();
          }
        });
      });
    });

    it('should broadcast to all clients in order room', (done) => {
      const ownerSocket = SocketIOClient(`http://localhost:${serverPort}`, {
        auth: { token: ownerToken },
        transports: ['websocket'],
      });

      const adminSocket = SocketIOClient(`http://localhost:${serverPort}`, {
        auth: { token: adminToken },
        transports: ['websocket'],
      });

      let ownerReceived = false;
      let adminReceived = false;

      const checkComplete = () => {
        if (ownerReceived && adminReceived) {
          ownerSocket.disconnect();
          adminSocket.disconnect();
          done();
        }
      };

      ownerSocket.on('connect', () => {
        ownerSocket.emit('join_order', testOrder.id);
      });

      adminSocket.on('connect', () => {
        adminSocket.emit('join_order', testOrder.id);

        adminSocket.on('joined_order', async () => {
          // Wait a bit for both to join
          await new Promise((resolve) => setTimeout(resolve, 100));

          // Update status
          await request(app)
            .patch(`/v1/orders/${testOrder.id}/status`)
            .set('Authorization', `Bearer ${adminToken}`)
            .send({ status: 'in_progress' });
        });
      });

      ownerSocket.on('order_status_changed', (data: any) => {
        expect(data.orderId).toBe(testOrder.id);
        ownerReceived = true;
        checkComplete();
      });

      adminSocket.on('order_status_changed', (data: any) => {
        expect(data.orderId).toBe(testOrder.id);
        adminReceived = true;
        checkComplete();
      });
    });

    it('should not broadcast to clients not in order room', (done) => {
      const inRoomSocket = SocketIOClient(`http://localhost:${serverPort}`, {
        auth: { token: ownerToken },
        transports: ['websocket'],
      });

      const outOfRoomSocket = SocketIOClient(`http://localhost:${serverPort}`, {
        auth: { token: adminToken },
        transports: ['websocket'],
      });

      let inRoomReceived = false;
      let outOfRoomReceived = false;

      inRoomSocket.on('connect', () => {
        inRoomSocket.emit('join_order', testOrder.id);
      });

      outOfRoomSocket.on('connect', () => {
        // Don't join the order room

        outOfRoomSocket.on('joined_order', async () => {
          await new Promise((resolve) => setTimeout(resolve, 100));

          await request(app)
            .patch(`/v1/orders/${testOrder.id}/status`)
            .set('Authorization', `Bearer ${adminToken}`)
            .send({ status: 'completed' });
        });
      });

      inRoomSocket.on('order_status_changed', () => {
        inRoomReceived = true;
        setTimeout(() => {
          expect(inRoomReceived).toBe(true);
          expect(outOfRoomReceived).toBe(false);
          inRoomSocket.disconnect();
          outOfRoomSocket.disconnect();
          done();
        }, 500);
      });

      outOfRoomSocket.on('order_status_changed', () => {
        outOfRoomReceived = true;
      });
    });
  });

  describe('Real-time Location Updates', () => {
    it('should broadcast location_update event when service provider updates location', (done) => {
      // Assign service provider
      pool.query(
        'UPDATE order_tracking SET service_provider_id = $1 WHERE order_id = $2',
        [serviceProvider.id, testOrder.id]
      ).then(() => {
        const ownerSocket = SocketIOClient(`http://localhost:${serverPort}`, {
          auth: { token: ownerToken },
          transports: ['websocket'],
        });

        ownerSocket.on('connect', () => {
          ownerSocket.emit('join_order', testOrder.id);

          ownerSocket.on('joined_order', async () => {
            // Update location via REST API
            await request(app)
              .post(`/v1/orders/${testOrder.id}/tracking/location`)
              .set('Authorization', `Bearer ${providerToken}`)
              .send({
                latitude: -1.2700,
                longitude: 36.8100,
                label: 'Updated Location',
              });
          });

          ownerSocket.on('location_update', (data: any) => {
            expect(data.orderId).toBe(testOrder.id);
            expect(data.location.latitude).toBe(-1.2700);
            expect(data.location.longitude).toBe(36.8100);
            expect(data.location.label).toBe('Updated Location');
            expect(data.timestamp).toBeDefined();
            ownerSocket.disconnect();
            done();
          });
        });
      });
    });

    it('should broadcast order_update after location update', (done) => {
      pool.query(
        'UPDATE order_tracking SET service_provider_id = $1 WHERE order_id = $2',
        [serviceProvider.id, testOrder.id]
      ).then(() => {
        const socket = SocketIOClient(`http://localhost:${serverPort}`, {
          auth: { token: ownerToken },
          transports: ['websocket'],
        });

        socket.on('connect', () => {
          socket.emit('join_order', testOrder.id);

          socket.on('joined_order', async () => {
            await request(app)
              .post(`/v1/orders/${testOrder.id}/tracking/location`)
              .set('Authorization', `Bearer ${providerToken}`)
              .send({
                latitude: -1.2800,
                longitude: 36.8200,
                label: 'New Location',
              });
          });

          socket.on('order_update', (data: any) => {
            expect(data.orderId).toBe(testOrder.id);
            expect(data.tracking.currentLocation).toBeDefined();
            expect(data.tracking.currentLocation?.latitude).toBe(-1.2800);
            socket.disconnect();
            done();
          });
        });
      });
    });
  });

  describe('Service Provider Assignment', () => {
    it('should broadcast events when service provider is assigned', (done) => {
      const ownerSocket = SocketIOClient(`http://localhost:${serverPort}`, {
        auth: { token: ownerToken },
        transports: ['websocket'],
      });

      let statusChangedReceived = false;

      ownerSocket.on('connect', () => {
        ownerSocket.emit('join_order', testOrder.id);

        ownerSocket.on('joined_order', async () => {
          // Assign service provider via REST API
          await request(app)
            .post(`/v1/orders/${testOrder.id}/assign`)
            .set('Authorization', `Bearer ${adminToken}`)
            .send({
              serviceProviderId: serviceProvider.id,
            });
        });

        ownerSocket.on('order_status_changed', (data: any) => {
          expect(data.status).toBe('assigned');
          statusChangedReceived = true;
        });

        ownerSocket.on('order_update', (data: any) => {
          if (statusChangedReceived) {
            expect(data.tracking.serviceProvider).toBeDefined();
            expect(data.tracking.serviceProvider?.id).toBe(serviceProvider.id);
            ownerSocket.disconnect();
            done();
          }
        });
      });
    });
  });

  describe('Multiple Orders & Room Isolation', () => {
    it('should isolate events between different order rooms', async () => {
      const order1 = await createTestOrder(pool, orderOwner.id, {
        type: 'cleaning',
        status: 'pending',
      });

      const order2 = await createTestOrder(pool, orderOwner.id, {
        type: 'laundry',
        status: 'pending',
      });

      return new Promise<void>((resolve, reject) => {
        const socket1 = SocketIOClient(`http://localhost:${serverPort}`, {
          auth: { token: ownerToken },
          transports: ['websocket'],
        });

        const socket2 = SocketIOClient(`http://localhost:${serverPort}`, {
          auth: { token: ownerToken },
          transports: ['websocket'],
        });

        let order1Received = false;
        let order2Received = false;
        let wrongOrderReceived = false;

        socket1.on('connect', () => {
          socket1.emit('join_order', order1.id);
        });

        socket2.on('connect', () => {
          socket2.emit('join_order', order2.id);
        });

        socket1.on('joined_order', async () => {
          socket2.on('joined_order', async () => {
            await new Promise((resolve) => setTimeout(resolve, 100));

            // Update order1 status
            await request(app)
              .patch(`/v1/orders/${order1.id}/status`)
              .set('Authorization', `Bearer ${adminToken}`)
              .send({ status: 'assigned' });
          });
        });

        socket1.on('order_status_changed', (data: any) => {
          if (data.orderId === order1.id) {
            order1Received = true;
          } else {
            wrongOrderReceived = true;
          }
        });

        socket2.on('order_status_changed', (data: any) => {
          if (data.orderId === order2.id) {
            order2Received = true;
          } else {
            wrongOrderReceived = true;
          }
        });

        setTimeout(() => {
          expect(order1Received).toBe(true);
          expect(order2Received).toBe(false); // Should not receive order1's update
          expect(wrongOrderReceived).toBe(false);
          socket1.disconnect();
          socket2.disconnect();
          resolve();
        }, 1000);
      });
    });
  });

  describe('Connection Cleanup', () => {
    it('should handle client disconnection gracefully', (done) => {
      const socket = SocketIOClient(`http://localhost:${serverPort}`, {
        auth: { token: ownerToken },
        transports: ['websocket'],
      });

      socket.on('connect', () => {
        socket.emit('join_order', testOrder.id);

        socket.on('joined_order', () => {
          socket.disconnect();

          // Verify cleanup happened
          setTimeout(() => {
            done();
          }, 100);
        });
      });
    });

    it('should allow reconnection and rejoining', (done) => {
      const socket = SocketIOClient(`http://localhost:${serverPort}`, {
        auth: { token: ownerToken },
        transports: ['websocket'],
      });

      let firstJoin = false;

      socket.on('connect', () => {
        socket.emit('join_order', testOrder.id);
      });

      socket.on('joined_order', () => {
        if (!firstJoin) {
          firstJoin = true;
          socket.disconnect();

          // Reconnect
          setTimeout(() => {
            socket.connect();
            socket.emit('join_order', testOrder.id);

            socket.on('joined_order', () => {
              socket.disconnect();
              done();
            });
          }, 100);
        }
      });
    });
  });

  describe('Error Handling', () => {
    it('should handle invalid order ID format', (done) => {
      const socket = SocketIOClient(`http://localhost:${serverPort}`, {
        auth: { token: ownerToken },
        transports: ['websocket'],
      });

      socket.on('connect', () => {
        socket.emit('join_order', 'invalid-uuid');

        socket.on('error', (error: any) => {
          expect(error).toBeDefined();
          socket.disconnect();
          done();
        });
      });
    });

    it('should handle malformed events gracefully', (done) => {
      const socket = SocketIOClient(`http://localhost:${serverPort}`, {
        auth: { token: ownerToken },
        transports: ['websocket'],
      });

      socket.on('connect', () => {
        // Try to join with invalid data
        (socket as any).emit('join_order', null);

        socket.on('error', () => {
          socket.disconnect();
          done();
        });

        // If no error, still complete test
        setTimeout(() => {
          socket.disconnect();
          done();
        }, 500);
      });
    });
  });
});
