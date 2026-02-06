import pool from '../config/database';
import {
  Conversation,
  ConversationType,
  ParticipantRole,
  Message,
  ConversationResponse,
  MessageResponse,
  CreateConversationInput,
  SendMessageInput,
} from '../models/Message';
import { NotFoundError, ValidationError, AuthorizationError } from '../utils/errors';

export class MessageService {
  /**
   * Create a new conversation
   */
  async createConversation(
    creatorId: string,
    input: CreateConversationInput
  ): Promise<ConversationResponse> {
    // Validate participants
    if (!input.participantIds || input.participantIds.length === 0) {
      throw new ValidationError('At least one participant is required');
    }

    // Ensure creator is in participants
    if (!input.participantIds.includes(creatorId)) {
      input.participantIds.push(creatorId);
    }

    // Validate order exists if orderId provided
    if (input.orderId) {
      const orderResult = await pool.query('SELECT id, owner_id FROM orders WHERE id = $1', [
        input.orderId,
      ]);
      if (orderResult.rows.length === 0) {
        throw new NotFoundError('Order');
      }

      // Ensure order owner is in participants
      const orderOwnerId = orderResult.rows[0].owner_id;
      if (!input.participantIds.includes(orderOwnerId)) {
        input.participantIds.push(orderOwnerId);
      }
    }

    // Validate all participants exist
    const userIds = [...new Set(input.participantIds)];
    const userCheckResult = await pool.query(
      `SELECT id, is_admin, is_agent FROM users WHERE id = ANY($1::uuid[])`,
      [userIds]
    );

    if (userCheckResult.rows.length !== userIds.length) {
      throw new ValidationError('One or more participants not found');
    }

    // Create conversation
    const conversationResult = await pool.query(
      `INSERT INTO conversations (order_id, type, subject)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [input.orderId || null, input.type, input.subject || null]
    );

    const conversation = conversationResult.rows[0] as Conversation;

    // Add participants
    for (const userId of userIds) {
      const user = userCheckResult.rows.find((u) => u.id === userId);
      let role = ParticipantRole.USER;
      
      if (user.is_admin) {
        role = ParticipantRole.ADMIN;
      } else if (user.is_agent) {
        role = ParticipantRole.AGENT;
      }

      await pool.query(
        `INSERT INTO conversation_participants (conversation_id, user_id, role)
         VALUES ($1, $2, $3)`,
        [conversation.id, userId, role]
      );
    }

    return this.getConversationById(conversation.id, creatorId);
  }

  /**
   * Get user's conversations
   */
  async getUserConversations(
    userId: string,
    filters: {
      type?: ConversationType;
      orderId?: string;
      limit?: number;
      offset?: number;
    } = {}
  ): Promise<{
    conversations: ConversationResponse[];
    total: number;
    limit: number;
    offset: number;
  }> {
    const limit = Math.min(filters.limit || 20, 100);
    const offset = filters.offset || 0;

    let query = `
      SELECT DISTINCT c.*
      FROM conversations c
      INNER JOIN conversation_participants cp ON c.id = cp.conversation_id
      WHERE cp.user_id = $1
    `;
    const params: any[] = [userId];
    let paramIndex = 2;

    if (filters.type) {
      query += ` AND c.type = $${paramIndex}`;
      params.push(filters.type);
      paramIndex++;
    }

    if (filters.orderId) {
      query += ` AND c.order_id = $${paramIndex}`;
      params.push(filters.orderId);
      paramIndex++;
    }

    // Get total count
    const countQuery = query.replace('SELECT DISTINCT c.*', 'SELECT COUNT(DISTINCT c.id) as total');
    const countResult = await pool.query(countQuery, params);
    const total = parseInt(countResult.rows[0].total, 10);

    // Get paginated results
    query += ` ORDER BY c.updated_at DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
    params.push(limit, offset);

    const result = await pool.query(query, params);
    const conversations: ConversationResponse[] = [];

    for (const row of result.rows) {
      const conversation = await this.getConversationById(row.id, userId);
      conversations.push(conversation);
    }

    return {
      conversations,
      total,
      limit,
      offset,
    };
  }

  /**
   * Get conversation by ID (with authorization check)
   */
  async getConversationById(
    conversationId: string,
    userId: string
  ): Promise<ConversationResponse> {
    // Check if user is participant
    const participantCheck = await pool.query(
      `SELECT * FROM conversation_participants
       WHERE conversation_id = $1 AND user_id = $2`,
      [conversationId, userId]
    );

    if (participantCheck.rows.length === 0) {
      throw new AuthorizationError('You are not a participant in this conversation');
    }

    // Get conversation
    const conversationResult = await pool.query(
      'SELECT * FROM conversations WHERE id = $1',
      [conversationId]
    );

    if (conversationResult.rows.length === 0) {
      throw new NotFoundError('Conversation');
    }

    const conversation = conversationResult.rows[0] as Conversation;

    // Get participants
    const participantsResult = await pool.query(
      `SELECT cp.*, u.email, u.name
       FROM conversation_participants cp
       JOIN users u ON cp.user_id = u.id
       WHERE cp.conversation_id = $1
       ORDER BY cp.joined_at`,
      [conversationId]
    );

    const participants = participantsResult.rows.map((row) => ({
      userId: row.user_id,
      role: row.role,
      joinedAt: row.joined_at.toISOString(),
      lastReadAt: row.last_read_at?.toISOString() || null,
    }));

    // Get last message
    const lastMessageResult = await pool.query(
      `SELECT id, content, sender_id, created_at
       FROM messages
       WHERE conversation_id = $1
       ORDER BY created_at DESC
       LIMIT 1`,
      [conversationId]
    );

    const lastMessage = lastMessageResult.rows.length > 0
      ? {
          id: lastMessageResult.rows[0].id,
          content: lastMessageResult.rows[0].content.substring(0, 100), // Preview
          senderId: lastMessageResult.rows[0].sender_id,
          createdAt: lastMessageResult.rows[0].created_at.toISOString(),
        }
      : null;

    // Get unread count for this user
    const participant = participantCheck.rows[0];
    const lastReadAt = participant.last_read_at || new Date(0);

    const unreadCountResult = await pool.query(
      `SELECT COUNT(*) as count
       FROM messages
       WHERE conversation_id = $1
       AND sender_id != $2
       AND created_at > $3`,
      [conversationId, userId, lastReadAt]
    );

    const unreadCount = parseInt(unreadCountResult.rows[0].count, 10);

    return {
      id: conversation.id,
      orderId: conversation.order_id,
      type: conversation.type,
      subject: conversation.subject,
      participants,
      lastMessage,
      unreadCount,
      createdAt: conversation.created_at.toISOString(),
      updatedAt: conversation.updated_at.toISOString(),
    };
  }

  /**
   * Get messages in conversation
   */
  async getConversationMessages(
    conversationId: string,
    userId: string,
    filters: {
      limit?: number;
      offset?: number;
    } = {}
  ): Promise<{
    messages: MessageResponse[];
    total: number;
    limit: number;
    offset: number;
  }> {
    // Check authorization
    await this.getConversationById(conversationId, userId);

    const limit = Math.min(filters.limit || 50, 100);
    const offset = filters.offset || 0;

    // Get total count
    const countResult = await pool.query(
      'SELECT COUNT(*) as total FROM messages WHERE conversation_id = $1',
      [conversationId]
    );
    const total = parseInt(countResult.rows[0].total, 10);

    // Get messages
    const messagesResult = await pool.query(
      `SELECT * FROM messages
       WHERE conversation_id = $1
       ORDER BY created_at DESC
       LIMIT $2 OFFSET $3`,
      [conversationId, limit, offset]
    );

    const messages = messagesResult.rows.map((row) => ({
      id: row.id,
      conversationId: row.conversation_id,
      senderId: row.sender_id,
      content: row.content,
      readAt: row.read_at?.toISOString() || null,
      createdAt: row.created_at.toISOString(),
      updatedAt: row.updated_at.toISOString(),
    })).reverse(); // Reverse to show oldest first

    return {
      messages,
      total,
      limit,
      offset,
    };
  }

  /**
   * Send message in conversation
   */
  async sendMessage(
    conversationId: string,
    senderId: string,
    input: SendMessageInput
  ): Promise<MessageResponse> {
    // Validate content
    if (!input.content || input.content.trim().length === 0) {
      throw new ValidationError('Message content is required');
    }

    if (input.content.length > 5000) {
      throw new ValidationError('Message content cannot exceed 5000 characters');
    }

    // Check authorization
    await this.getConversationById(conversationId, senderId);

    // Create message
    const messageResult = await pool.query(
      `INSERT INTO messages (conversation_id, sender_id, content)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [conversationId, senderId, input.content.trim()]
    );

    const message = messageResult.rows[0] as Message;

    // Update sender's last_read_at (they've seen their own message)
    await pool.query(
      `UPDATE conversation_participants
       SET last_read_at = NOW()
       WHERE conversation_id = $1 AND user_id = $2`,
      [conversationId, senderId]
    );

    return {
      id: message.id,
      conversationId: message.conversation_id,
      senderId: message.sender_id,
      content: message.content,
      readAt: message.read_at?.toISOString() || null,
      createdAt: message.created_at.toISOString(),
      updatedAt: message.updated_at.toISOString(),
    };
  }

  /**
   * Mark message as read
   */
  async markMessageAsRead(messageId: string, userId: string): Promise<MessageResponse> {
    // Get message
    const messageResult = await pool.query(
      'SELECT * FROM messages WHERE id = $1',
      [messageId]
    );

    if (messageResult.rows.length === 0) {
      throw new NotFoundError('Message');
    }

    const message = messageResult.rows[0] as Message;

    // Check authorization
    await this.getConversationById(message.conversation_id, userId);

    // Update read_at if not already read
    if (!message.read_at) {
      await pool.query(
        'UPDATE messages SET read_at = NOW() WHERE id = $1',
        [messageId]
      );
    }

    // Update user's last_read_at in conversation
    await pool.query(
      `UPDATE conversation_participants
       SET last_read_at = NOW()
       WHERE conversation_id = $1 AND user_id = $2`,
      [message.conversation_id, userId]
    );

    const updatedMessageResult = await pool.query(
      'SELECT * FROM messages WHERE id = $1',
      [messageId]
    );

    const updatedMessage = updatedMessageResult.rows[0] as Message;

    return {
      id: updatedMessage.id,
      conversationId: updatedMessage.conversation_id,
      senderId: updatedMessage.sender_id,
      content: updatedMessage.content,
      readAt: updatedMessage.read_at?.toISOString() || null,
      createdAt: updatedMessage.created_at.toISOString(),
      updatedAt: updatedMessage.updated_at.toISOString(),
    };
  }

  /**
   * Mark all messages in conversation as read
   */
  async markConversationAsRead(
    conversationId: string,
    userId: string
  ): Promise<void> {
    // Check authorization
    await this.getConversationById(conversationId, userId);

    // Update user's last_read_at
    await pool.query(
      `UPDATE conversation_participants
       SET last_read_at = NOW()
       WHERE conversation_id = $1 AND user_id = $2`,
      [conversationId, userId]
    );

    // Mark all unread messages as read
    await pool.query(
      `UPDATE messages
       SET read_at = NOW()
       WHERE conversation_id = $1
       AND sender_id != $2
       AND read_at IS NULL`,
      [conversationId, userId]
    );
  }

  /**
   * Create order conversation (auto-created when order is created)
   */
  async createOrderConversation(orderId: string, orderOwnerId: string): Promise<string> {
    // Check if conversation already exists
    const existingResult = await pool.query(
      'SELECT id FROM conversations WHERE order_id = $1',
      [orderId]
    );

    if (existingResult.rows.length > 0) {
      return existingResult.rows[0].id;
    }

    // Get order details
    const orderResult = await pool.query(
      'SELECT id, type, owner_id FROM orders WHERE id = $1',
      [orderId]
    );

    if (orderResult.rows.length === 0) {
      throw new NotFoundError('Order');
    }

    const order = orderResult.rows[0];

    // Create conversation
    const conversationResult = await pool.query(
      `INSERT INTO conversations (order_id, type, subject)
       VALUES ($1, $2, $3)
       RETURNING id`,
      [
        orderId,
        ConversationType.ORDER,
        `Order ${orderId.substring(0, 8)} - ${order.type}`,
      ]
    );

    const conversationId = conversationResult.rows[0].id;

    // Add order owner as participant
    await pool.query(
      `INSERT INTO conversation_participants (conversation_id, user_id, role)
       VALUES ($1, $2, $3)`,
      [conversationId, orderOwnerId, ParticipantRole.USER]
    );

    // TODO: Add service provider when order is assigned
    // For now, just the order owner is added

    return conversationId;
  }
}

export const messageService = new MessageService();
