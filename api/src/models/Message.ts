export enum ConversationType {
  ORDER = 'order',
  GENERAL = 'general',
  SUPPORT = 'support',
}

export enum ParticipantRole {
  USER = 'user',
  AGENT = 'agent',
  ADMIN = 'admin',
  SERVICE_PROVIDER = 'service_provider',
}

export interface Conversation {
  id: string;
  order_id: string | null;
  type: ConversationType;
  subject: string | null;
  created_at: Date;
  updated_at: Date;
}

export interface ConversationParticipant {
  id: string;
  conversation_id: string;
  user_id: string;
  role: ParticipantRole;
  joined_at: Date;
  last_read_at: Date | null;
}

export interface Message {
  id: string;
  conversation_id: string;
  sender_id: string;
  content: string;
  read_at: Date | null;
  created_at: Date;
  updated_at: Date;
}

export interface ConversationResponse {
  id: string;
  orderId: string | null;
  type: ConversationType;
  subject: string | null;
  participants: ParticipantResponse[];
  lastMessage: MessagePreviewResponse | null;
  unreadCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface ParticipantResponse {
  userId: string;
  role: ParticipantRole;
  joinedAt: string;
  lastReadAt: string | null;
}

export interface MessagePreviewResponse {
  id: string;
  content: string;
  senderId: string;
  createdAt: string;
}

export interface MessageResponse {
  id: string;
  conversationId: string;
  senderId: string;
  content: string;
  readAt: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface CreateConversationInput {
  orderId?: string;
  type: ConversationType;
  subject?: string;
  participantIds: string[];
}

export interface SendMessageInput {
  content: string;
}

export interface ConversationWithMessagesResponse extends ConversationResponse {
  messages: MessageResponse[];
}
