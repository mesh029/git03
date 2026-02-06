import request from 'supertest';
import { getTestApp, initializeTestApp, setupTestDatabase, cleanupTestDatabase, closeTestConnections } from '../setup';
import { createTestUser, createTestOrder } from '../helpers';

describe('Messages API Integration Tests', () => {
  let app: any;
  let pool: any;
  let user1: any;
  let user2: any;
  let agent: any;
  let user1Token: string;
  let user2Token: string;
  let agentToken: string;

  beforeAll(async () => {
    await initializeTestApp();
    app = getTestApp();
    pool = await setupTestDatabase();
  });

  beforeEach(async () => {
    await cleanupTestDatabase();

    // Create users
    user1 = await createTestUser(pool, {
      email: 'user1@juax.test',
      password: 'Test123!@#',
      name: 'User 1',
    });

    const user1LoginResponse = await request(app)
      .post('/v1/auth/login')
      .send({
        email: 'user1@juax.test',
        password: 'Test123!@#',
      });

    if (user1LoginResponse.status !== 200 || !user1LoginResponse.body.success) {
      throw new Error(`User1 login failed: ${JSON.stringify(user1LoginResponse.body)}`);
    }
    user1Token = user1LoginResponse.body.data.tokens.accessToken;

    user2 = await createTestUser(pool, {
      email: 'user2@juax.test',
      password: 'Test123!@#',
      name: 'User 2',
    });

    const user2LoginResponse = await request(app)
      .post('/v1/auth/login')
      .send({
        email: 'user2@juax.test',
        password: 'Test123!@#',
      });

    if (user2LoginResponse.status !== 200 || !user2LoginResponse.body.success) {
      throw new Error(`User2 login failed: ${JSON.stringify(user2LoginResponse.body)}`);
    }
    user2Token = user2LoginResponse.body.data.tokens.accessToken;

    agent = await createTestUser(pool, {
      email: 'agent@juax.test',
      password: 'Test123!@#',
      name: 'Agent User',
      is_agent: true,
    });

    const agentLoginResponse = await request(app)
      .post('/v1/auth/login')
      .send({
        email: 'agent@juax.test',
        password: 'Test123!@#',
      });

    if (agentLoginResponse.status !== 200 || !agentLoginResponse.body.success) {
      throw new Error(`Agent login failed: ${JSON.stringify(agentLoginResponse.body)}`);
    }
    agentToken = agentLoginResponse.body.data.tokens.accessToken;
  });

  afterAll(async () => {
    await closeTestConnections();
  });

  describe('POST /v1/messages/conversations', () => {
    it('should create a general conversation', async () => {
      const response = await request(app)
        .post('/v1/messages/conversations')
        .set('Authorization', `Bearer ${user1Token}`)
        .send({
          type: 'general',
          subject: 'Test Conversation',
          participantIds: [user2.id],
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.type).toBe('general');
      expect(response.body.data.subject).toBe('Test Conversation');
      expect(response.body.data.participants.length).toBe(2);
    });

    it('should create an order conversation', async () => {
      // Create an order first
      const order = await createTestOrder(pool, user1.id);

      const response = await request(app)
        .post('/v1/messages/conversations')
        .set('Authorization', `Bearer ${user1Token}`)
        .send({
          type: 'order',
          orderId: order.id,
          participantIds: [agent.id],
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.type).toBe('order');
      expect(response.body.data.orderId).toBe(order.id);
    });

    it('should fail without authentication', async () => {
      const response = await request(app)
        .post('/v1/messages/conversations')
        .send({
          type: 'general',
          participantIds: [user2.id],
        });

      expect(response.status).toBe(401);
      expect(response.body.success).toBe(false);
    });

    it('should fail with invalid participant IDs', async () => {
      const response = await request(app)
        .post('/v1/messages/conversations')
        .set('Authorization', `Bearer ${user1Token}`)
        .send({
          type: 'general',
          participantIds: ['invalid-uuid'],
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /v1/messages/conversations', () => {
    let conversationId: string;

    beforeEach(async () => {
      // Create a conversation
      const createResponse = await request(app)
        .post('/v1/messages/conversations')
        .set('Authorization', `Bearer ${user1Token}`)
        .send({
          type: 'general',
          subject: 'Test Conversation',
          participantIds: [user2.id],
        });

      conversationId = createResponse.body.data.id;
    });

    it('should list user conversations', async () => {
      const response = await request(app)
        .get('/v1/messages/conversations')
        .set('Authorization', `Bearer ${user1Token}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.conversations.length).toBeGreaterThan(0);
      expect(response.body.data.conversations[0].id).toBe(conversationId);
    });

    it('should filter conversations by type', async () => {
      const response = await request(app)
        .get('/v1/messages/conversations?type=general')
        .set('Authorization', `Bearer ${user1Token}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      response.body.data.conversations.forEach((conv: any) => {
        expect(conv.type).toBe('general');
      });
    });

    it('should support pagination', async () => {
      const response = await request(app)
        .get('/v1/messages/conversations?limit=1&offset=0')
        .set('Authorization', `Bearer ${user1Token}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.conversations.length).toBeLessThanOrEqual(1);
    });
  });

  describe('GET /v1/messages/conversations/:id', () => {
    let conversationId: string;

    beforeEach(async () => {
      const createResponse = await request(app)
        .post('/v1/messages/conversations')
        .set('Authorization', `Bearer ${user1Token}`)
        .send({
          type: 'general',
          subject: 'Test Conversation',
          participantIds: [user2.id],
        });

      conversationId = createResponse.body.data.id;
    });

    it('should get conversation details', async () => {
      const response = await request(app)
        .get(`/v1/messages/conversations/${conversationId}`)
        .set('Authorization', `Bearer ${user1Token}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.id).toBe(conversationId);
      expect(response.body.data.participants.length).toBe(2);
    });

    it('should fail for non-participant', async () => {
      const nonParticipant = await createTestUser(pool, {
        email: 'nonparticipant@juax.test',
        password: 'Test123!@#',
        name: 'Non Participant',
      });

      const loginResponse = await request(app)
        .post('/v1/auth/login')
        .send({
          email: 'nonparticipant@juax.test',
          password: 'Test123!@#',
        });

      const nonParticipantToken = loginResponse.body.data.tokens.accessToken;

      const response = await request(app)
        .get(`/v1/messages/conversations/${conversationId}`)
        .set('Authorization', `Bearer ${nonParticipantToken}`);

      expect(response.status).toBe(403);
      expect(response.body.success).toBe(false);
    });
  });

  describe('POST /v1/messages/conversations/:id/messages', () => {
    let conversationId: string;

    beforeEach(async () => {
      const createResponse = await request(app)
        .post('/v1/messages/conversations')
        .set('Authorization', `Bearer ${user1Token}`)
        .send({
          type: 'general',
          subject: 'Test Conversation',
          participantIds: [user2.id],
        });

      conversationId = createResponse.body.data.id;
    });

    it('should send a message in conversation', async () => {
      const response = await request(app)
        .post(`/v1/messages/conversations/${conversationId}/messages`)
        .set('Authorization', `Bearer ${user1Token}`)
        .send({
          content: 'Hello, this is a test message!',
        });

      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.content).toBe('Hello, this is a test message!');
      expect(response.body.data.senderId).toBe(user1.id);
      expect(response.body.data.conversationId).toBe(conversationId);
    });

    it('should fail with empty content', async () => {
      const response = await request(app)
        .post(`/v1/messages/conversations/${conversationId}/messages`)
        .set('Authorization', `Bearer ${user1Token}`)
        .send({
          content: '',
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    it('should fail for non-participant', async () => {
      const nonParticipant = await createTestUser(pool, {
        email: 'nonparticipant@juax.test',
        password: 'Test123!@#',
        name: 'Non Participant',
      });

      const loginResponse = await request(app)
        .post('/v1/auth/login')
        .send({
          email: 'nonparticipant@juax.test',
          password: 'Test123!@#',
        });

      const nonParticipantToken = loginResponse.body.data.tokens.accessToken;

      const response = await request(app)
        .post(`/v1/messages/conversations/${conversationId}/messages`)
        .set('Authorization', `Bearer ${nonParticipantToken}`)
        .send({
          content: 'Unauthorized message',
        });

      expect(response.status).toBe(403);
      expect(response.body.success).toBe(false);
    });
  });

  describe('GET /v1/messages/conversations/:id/messages', () => {
    let conversationId: string;
    let messageId: string;

    beforeEach(async () => {
      const createResponse = await request(app)
        .post('/v1/messages/conversations')
        .set('Authorization', `Bearer ${user1Token}`)
        .send({
          type: 'general',
          subject: 'Test Conversation',
          participantIds: [user2.id],
        });

      conversationId = createResponse.body.data.id;

      // Send a message
      const messageResponse = await request(app)
        .post(`/v1/messages/conversations/${conversationId}/messages`)
        .set('Authorization', `Bearer ${user1Token}`)
        .send({
          content: 'Test message',
        });

      messageId = messageResponse.body.data.id;
    });

    it('should get messages in conversation', async () => {
      const response = await request(app)
        .get(`/v1/messages/conversations/${conversationId}/messages`)
        .set('Authorization', `Bearer ${user1Token}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.messages.length).toBeGreaterThan(0);
      expect(response.body.data.messages[0].id).toBe(messageId);
    });

    it('should support pagination', async () => {
      const response = await request(app)
        .get(`/v1/messages/conversations/${conversationId}/messages?limit=1&offset=0`)
        .set('Authorization', `Bearer ${user1Token}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.messages.length).toBeLessThanOrEqual(1);
    });
  });

  describe('PATCH /v1/messages/:id/read', () => {
    let conversationId: string;
    let messageId: string;

    beforeEach(async () => {
      const createResponse = await request(app)
        .post('/v1/messages/conversations')
        .set('Authorization', `Bearer ${user1Token}`)
        .send({
          type: 'general',
          subject: 'Test Conversation',
          participantIds: [user2.id],
        });

      conversationId = createResponse.body.data.id;

      // Send a message from user1
      const messageResponse = await request(app)
        .post(`/v1/messages/conversations/${conversationId}/messages`)
        .set('Authorization', `Bearer ${user1Token}`)
        .send({
          content: 'Test message',
        });

      messageId = messageResponse.body.data.id;
    });

    it('should mark message as read', async () => {
      const response = await request(app)
        .patch(`/v1/messages/${messageId}/read`)
        .set('Authorization', `Bearer ${user2Token}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.readAt).toBeDefined();
    });

    it('should fail for non-participant', async () => {
      const nonParticipant = await createTestUser(pool, {
        email: 'nonparticipant@juax.test',
        password: 'Test123!@#',
        name: 'Non Participant',
      });

      const loginResponse = await request(app)
        .post('/v1/auth/login')
        .send({
          email: 'nonparticipant@juax.test',
          password: 'Test123!@#',
        });

      const nonParticipantToken = loginResponse.body.data.tokens.accessToken;

      const response = await request(app)
        .patch(`/v1/messages/${messageId}/read`)
        .set('Authorization', `Bearer ${nonParticipantToken}`);

      expect(response.status).toBe(403);
      expect(response.body.success).toBe(false);
    });
  });

  describe('PATCH /v1/messages/conversations/:id/read', () => {
    let conversationId: string;

    beforeEach(async () => {
      const createResponse = await request(app)
        .post('/v1/messages/conversations')
        .set('Authorization', `Bearer ${user1Token}`)
        .send({
          type: 'general',
          subject: 'Test Conversation',
          participantIds: [user2.id],
        });

      conversationId = createResponse.body.data.id;

      // Send multiple messages
      await request(app)
        .post(`/v1/messages/conversations/${conversationId}/messages`)
        .set('Authorization', `Bearer ${user1Token}`)
        .send({ content: 'Message 1' });

      await request(app)
        .post(`/v1/messages/conversations/${conversationId}/messages`)
        .set('Authorization', `Bearer ${user1Token}`)
        .send({ content: 'Message 2' });
    });

    it('should mark all messages in conversation as read', async () => {
      const response = await request(app)
        .patch(`/v1/messages/conversations/${conversationId}/read`)
        .set('Authorization', `Bearer ${user2Token}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.message).toContain('marked as read');
    });
  });

  describe('Order Conversation Auto-Creation', () => {
    it('should auto-create conversation when order is created', async () => {
      // Create an order
      const orderResponse = await request(app)
        .post('/v1/orders')
        .set('Authorization', `Bearer ${user1Token}`)
        .send({
          type: 'cleaning',
          location: {
            latitude: -1.2634,
            longitude: 36.8007,
            label: 'Westlands, Nairobi',
          },
          details: {
            service: 'deepCleaning',
            rooms: 3,
          },
        });

      expect(orderResponse.status).toBe(201);
      const orderId = orderResponse.body.data.id;

      // Wait a bit for async conversation creation
      await new Promise(resolve => setTimeout(resolve, 100));

      // Check if conversation was created
      const conversationsResponse = await request(app)
        .get('/v1/messages/conversations?type=order')
        .set('Authorization', `Bearer ${user1Token}`);

      expect(conversationsResponse.status).toBe(200);
      const orderConversation = conversationsResponse.body.data.conversations.find(
        (c: any) => c.orderId === orderId
      );

      expect(orderConversation).toBeDefined();
      expect(orderConversation.type).toBe('order');
    });
  });
});
