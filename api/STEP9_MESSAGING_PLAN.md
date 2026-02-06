# Step 9: Messaging System - Implementation Plan

## Overview
Implement a comprehensive messaging system to enable communication between users, agents, and order-related messaging.

## Business Requirements

### Message Types

1. **Order-Related Messages**
   - Messages linked to specific orders
   - User ↔ Service Provider communication
   - Order status updates via messages
   - Order clarification requests

2. **General Messages**
   - User-to-agent communication
   - Support messages
   - General inquiries

### Conversation Structure

- **Conversations**: Threads between two or more participants
- **Messages**: Individual messages within a conversation
- **Participants**: Users involved in the conversation
- **Read Status**: Track which messages have been read

### Features

- Create conversations
- Send messages
- List conversations
- Get conversation messages
- Mark messages as read
- Order-linked conversations
- Real-time updates (polling initially, WebSocket later)

## Database Schema

### `conversations` Table
```sql
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL CHECK (type IN ('order', 'general', 'support')),
  subject VARCHAR(255),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### `conversation_participants` Table
```sql
CREATE TABLE conversation_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role VARCHAR(50) NOT NULL CHECK (role IN ('user', 'agent', 'admin', 'service_provider')),
  joined_at TIMESTAMP DEFAULT NOW(),
  last_read_at TIMESTAMP,
  UNIQUE(conversation_id, user_id)
);
```

### `messages` Table
```sql
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

## API Endpoints

### User Endpoints

1. **GET /v1/messages/conversations**
   - List user's conversations
   - Query: `?type=order&orderId=...`
   - Returns: List of conversations with last message preview

2. **GET /v1/messages/conversations/:id**
   - Get conversation details
   - Returns: Conversation info and participants

3. **GET /v1/messages/conversations/:id/messages**
   - Get messages in conversation
   - Query: `?limit=50&offset=0`
   - Returns: Paginated messages

4. **POST /v1/messages/conversations**
   - Create new conversation
   - Body: `{ orderId?: string, type: 'order' | 'general' | 'support', subject?: string, participantIds: string[] }`
   - Returns: Created conversation

5. **POST /v1/messages/conversations/:id/messages**
   - Send message in conversation
   - Body: `{ content: string }`
   - Returns: Created message

6. **PATCH /v1/messages/:id/read**
   - Mark message as read
   - Returns: Updated message

7. **PATCH /v1/messages/conversations/:id/read**
   - Mark all messages in conversation as read
   - Returns: Success message

### Admin Endpoints

8. **GET /v1/admin/messages/conversations**
   - List all conversations (with filters)
   - Query: `?type=order&status=active`

9. **GET /v1/admin/messages/conversations/:id**
   - Get conversation details (admin view)

## Implementation Steps

### 1. Database Migration
- Create `conversations` table
- Create `conversation_participants` table
- Create `messages` table
- Add indexes for efficient queries
- Add triggers for updated_at

### 2. Models & Types
- `Conversation` model
- `ConversationParticipant` model
- `Message` model
- `ConversationType` enum
- `ParticipantRole` enum
- Response interfaces

### 3. Message Service
- `createConversation()` - Create new conversation
- `getUserConversations()` - List user's conversations
- `getConversationById()` - Get conversation details
- `getConversationMessages()` - Get messages in conversation
- `sendMessage()` - Send message in conversation
- `markMessageAsRead()` - Mark message as read
- `markConversationAsRead()` - Mark all messages as read
- `addParticipant()` - Add participant to conversation
- `removeParticipant()` - Remove participant from conversation

### 4. Message Controller
- Handle HTTP requests
- Validate input
- Call service methods
- Return formatted responses

### 5. Message Routes
- Define all endpoints
- Apply authentication middleware
- Apply admin middleware where needed
- Apply rate limiting

### 6. Message Validators
- Joi schemas for:
  - Create conversation
  - Send message
  - Mark as read
  - Admin queries

### 7. Integration with Orders
- Auto-create conversation when order is created
- Link messages to orders
- Order status updates via messages

### 8. Tests
- Unit tests for service methods
- Integration tests for all endpoints
- Test conversation creation
- Test message sending
- Test read status tracking

## Business Logic

### Conversation Creation

1. **Order Conversation**
   - Auto-created when order is created
   - Participants: Order owner + Service provider (if assigned)
   - Type: 'order'
   - Subject: Order ID or order title

2. **General Conversation**
   - User-initiated
   - Participants: User + Agent/Admin
   - Type: 'general' or 'support'
   - Subject: User-provided

### Message Sending

- Validate sender is participant
- Create message record
- Update conversation updated_at
- Update sender's last_read_at
- Return created message

### Read Status

- Track when user reads a message
- Track when user reads entire conversation
- Show unread count per conversation
- Show unread indicator

## Security Considerations

- Users can only access conversations they're participants in
- Users can only send messages in conversations they're part of
- Admins can access all conversations
- Message content validation (no XSS)
- Rate limiting on message sending

## Future Enhancements

- WebSocket for real-time delivery
- File attachments
- Message reactions
- Message editing/deletion
- Typing indicators
- Push notifications
- Email notifications for messages

## Testing Strategy

1. **Unit Tests**
   - Service methods
   - Conversation logic
   - Message sending logic
   - Read status tracking

2. **Integration Tests**
   - All endpoints
   - Conversation creation flows
   - Message sending flows
   - Read status updates
   - Authorization checks

3. **Edge Cases**
   - Multiple participants
   - Order-linked conversations
   - Deleted orders
   - User leaving conversation

## Next Steps

1. Create database migration
2. Implement models and types
3. Build message service
4. Create controllers and routes
5. Add validators
6. Write comprehensive tests
7. Integrate with order creation
