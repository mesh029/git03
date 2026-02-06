import 'package:flutter/foundation.dart';
import '../services/local_storage_service.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

// Dummy messages database - replace with API later
class DummyMessages {
  static final List<Message> allMessages = [
    // Messages between admin and premium user
    Message(
      id: 'msg_1',
      conversationId: 'conv_admin_premium',
      senderId: 'user_premium_all',
      receiverId: 'user_admin',
      content: 'Hello, I need help with my order #123456',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    Message(
      id: 'msg_2',
      conversationId: 'conv_admin_premium',
      senderId: 'user_admin',
      receiverId: 'user_premium_all',
      content: 'Hello! I can help you with that. What seems to be the issue?',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      isRead: true,
    ),
    Message(
      id: 'msg_3',
      conversationId: 'conv_admin_premium',
      senderId: 'user_premium_all',
      receiverId: 'user_admin',
      content: 'The cleaning service was supposed to arrive at 2 PM but they haven\'t shown up yet.',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      isRead: true,
    ),
    Message(
      id: 'msg_4',
      conversationId: 'conv_admin_premium',
      senderId: 'user_admin',
      receiverId: 'user_premium_all',
      content: 'I apologize for the delay. Let me check with the service provider and get back to you immediately.',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      isRead: true,
    ),
    Message(
      id: 'msg_5',
      conversationId: 'conv_admin_premium',
      senderId: 'user_admin',
      receiverId: 'user_premium_all',
      content: 'Update: The cleaning team is on their way and should arrive within 30 minutes. Sorry for the inconvenience!',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      isRead: false,
    ),
    // Messages between admin and freemium user
    Message(
      id: 'msg_6',
      conversationId: 'conv_admin_freemium',
      senderId: 'user_freemium',
      receiverId: 'user_admin',
      content: 'Hi, I want to upgrade to premium. How do I do that?',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    Message(
      id: 'msg_7',
      conversationId: 'conv_admin_freemium',
      senderId: 'user_admin',
      receiverId: 'user_freemium',
      content: 'Hello! You can upgrade to premium through the Profile section. Premium gives you access to Saka Keja (rentals) and Fresh Keja (cleaning/laundry) services.',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: -1)),
      isRead: true,
    ),
    // Messages between two users
    Message(
      id: 'msg_8',
      conversationId: 'conv_premium_freemium',
      senderId: 'user_premium_all',
      receiverId: 'user_freemium',
      content: 'Hey! How\'s the service quality?',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
    Message(
      id: 'msg_9',
      conversationId: 'conv_premium_freemium',
      senderId: 'user_freemium',
      receiverId: 'user_premium_all',
      content: 'It\'s been great! The cleaning service is very thorough.',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: -2)),
      isRead: true,
    ),
  ];

  static List<Message> getMessagesForConversation(String conversationId) {
    return allMessages
        .where((msg) => msg.conversationId == conversationId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  static List<Message> getMessagesForUser(String userId) {
    return allMessages
        .where((msg) => msg.senderId == userId || msg.receiverId == userId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static List<Conversation> getConversationsForUser(String userId) {
    final messages = getMessagesForUser(userId);
    final conversationMap = <String, Conversation>{};

    for (var message in messages) {
      final otherUserId = message.senderId == userId
          ? message.receiverId
          : message.senderId;

      final conversationId = _getConversationId(userId, otherUserId);

      if (!conversationMap.containsKey(conversationId)) {
        conversationMap[conversationId] = Conversation(
          id: conversationId,
          participant1Id: userId,
          participant2Id: otherUserId,
          lastMessageId: message.id,
          lastMessageAt: message.timestamp,
          unreadCount: message.receiverId == userId && !message.isRead ? 1 : 0,
        );
      } else {
        final conv = conversationMap[conversationId]!;
        if (conv.lastMessageAt == null ||
            message.timestamp.isAfter(conv.lastMessageAt!)) {
          conversationMap[conversationId] = Conversation(
            id: conv.id,
            participant1Id: conv.participant1Id,
            participant2Id: conv.participant2Id,
            lastMessageId: message.id,
            lastMessageAt: message.timestamp,
            unreadCount: conv.unreadCount +
                (message.receiverId == userId && !message.isRead ? 1 : 0),
          );
        } else {
          conversationMap[conversationId] = Conversation(
            id: conv.id,
            participant1Id: conv.participant1Id,
            participant2Id: conv.participant2Id,
            lastMessageId: conv.lastMessageId,
            lastMessageAt: conv.lastMessageAt,
            unreadCount: conv.unreadCount +
                (message.receiverId == userId && !message.isRead ? 1 : 0),
          );
        }
      }
    }

    return conversationMap.values.toList()
      ..sort((a, b) {
        if (a.lastMessageAt == null) return 1;
        if (b.lastMessageAt == null) return -1;
        return b.lastMessageAt!.compareTo(a.lastMessageAt!);
      });
  }

  static String getConversationId(String userId1, String userId2) {
    // Backward compatible mapping for seeded demo conversations
    // (seed data uses legacy IDs like conv_admin_premium)
    final a = userId1;
    final b = userId2;
    bool pair(String x, String y) => (a == x && b == y) || (a == y && b == x);

    if (pair('user_admin', 'user_premium_all')) return 'conv_admin_premium';
    if (pair('user_admin', 'user_freemium')) return 'conv_admin_freemium';
    if (pair('user_premium_all', 'user_freemium')) return 'conv_premium_freemium';

    final sorted = [userId1, userId2]..sort();
    return 'conv_${sorted[0]}_${sorted[1]}';
  }
  
  // Keep private method for backward compatibility
  static String _getConversationId(String userId1, String userId2) {
    return getConversationId(userId1, userId2);
  }

  static User? getUserById(String userId) {
    // TODO: Replace with API call to get user by ID
    // For now, return null - this will be replaced when we integrate user API
    return null;
  }
}

class MessagesProvider extends ChangeNotifier {
  List<Conversation> _conversations = [];
  List<Message> _currentMessages = [];
  String? _currentConversationId;
  bool _isLoading = false;

  List<Conversation> get conversations => _conversations;
  List<Message> get currentMessages => _currentMessages;
  String? get currentConversationId => _currentConversationId;
  bool get isLoading => _isLoading;

  MessagesProvider() {
    _restoreMessages();
  }

  Future<void> _restoreMessages() async {
    try {
      final stored = await LocalStorageService.getMessagesJson();
      if (stored != null) {
        DummyMessages.allMessages
          ..clear()
          ..addAll(stored.map(Message.fromJson));
      } else {
        await LocalStorageService.setMessagesJson(
          DummyMessages.allMessages.map((m) => m.toJson()).toList(),
        );
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _persistMessages() async {
    await LocalStorageService.setMessagesJson(
      DummyMessages.allMessages.map((m) => m.toJson()).toList(),
    );
  }

  // Load conversations for a user
  Future<void> loadConversations(String userId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    _conversations = DummyMessages.getConversationsForUser(userId);
    _isLoading = false;
    notifyListeners();
  }

  // Load messages for a conversation
  Future<void> loadMessages(String conversationId) async {
    _isLoading = true;
    _currentConversationId = conversationId;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 200));

    _currentMessages = DummyMessages.getMessagesForConversation(conversationId);
    _isLoading = false;
    notifyListeners();
  }

  // Send a message
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
  }) async {
    if (content.trim().isEmpty) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 200));

    final conversationId = DummyMessages.getConversationId(senderId, receiverId);
    final message = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      content: content.trim(),
      type: MessageType.text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    // Add message to dummy database
    DummyMessages.allMessages.add(message);
    await _persistMessages();
    
    // Update current messages if we're viewing this conversation
    if (_currentConversationId == conversationId) {
      _currentMessages.add(message);
    }
    
    // Reload conversations to update last message
    _conversations = DummyMessages.getConversationsForUser(senderId);

    _isLoading = false;
    notifyListeners();
  }

  // Mark messages as read
  Future<void> markAsRead(String conversationId, String userId) async {
    bool changed = false;
    for (var i = 0; i < DummyMessages.allMessages.length; i++) {
      final msg = DummyMessages.allMessages[i];
      if (msg.conversationId == conversationId &&
          msg.receiverId == userId &&
          !msg.isRead) {
        DummyMessages.allMessages[i] = Message(
          id: msg.id,
          conversationId: msg.conversationId,
          senderId: msg.senderId,
          receiverId: msg.receiverId,
          content: msg.content,
          type: msg.type,
          timestamp: msg.timestamp,
          isRead: true,
        );
        changed = true;
      }
    }
    await _persistMessages();
    if (changed) {
      _conversations = DummyMessages.getConversationsForUser(userId);
      if (_currentConversationId == conversationId) {
        _currentMessages = DummyMessages.getMessagesForConversation(conversationId);
      }
    }
    notifyListeners();
  }
}
