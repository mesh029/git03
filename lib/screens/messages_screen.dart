import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/messages_provider.dart';
import '../providers/auth_provider.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../widgets/bottom_navigation_bar.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'admin_orders_screen.dart';
import 'agent_dashboard_screen.dart';
import '../providers/messages_provider.dart' show DummyMessages;
import '../providers/auth_provider.dart' show DummyUsers;

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConversations();
    });
  }

  void _loadConversations() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messagesProvider = Provider.of<MessagesProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      messagesProvider.loadConversations(authProvider.currentUser!.id);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload conversations when screen becomes visible
    _loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Messages',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              if (authProvider.currentUser == null) return const SizedBox.shrink();
              
              return IconButton(
                icon: const Icon(Icons.add_comment),
                onPressed: () => _showNewConversationDialog(context, authProvider.currentUser!.id),
                tooltip: 'New conversation',
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, MessagesProvider>(
        builder: (context, authProvider, messagesProvider, _) {
          if (authProvider.currentUser == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please log in to view messages',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          if (messagesProvider.isLoading && messagesProvider.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (messagesProvider.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation with admin or other users',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: messagesProvider.conversations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final conversation = messagesProvider.conversations[index];
              final otherUserId = conversation.getOtherParticipantId(authProvider.currentUser!.id);
              final otherUser = DummyMessages.getUserById(otherUserId);
              final lastMessage = conversation.lastMessageId != null
                  ? DummyMessages.allMessages.firstWhere(
                      (msg) => msg.id == conversation.lastMessageId,
                      orElse: () => DummyMessages.allMessages.first,
                    )
                  : null;

              return _buildConversationCard(
                context,
                conversation,
                otherUser,
                lastMessage,
                messagesProvider,
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return AppBottomNavigationBar(
            currentIndex: 5,
            onTap: (index) {
              if (index == 0) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              } else if (index == 1) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              } else if (index == 2) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const OrdersScreen()),
                  (route) => false,
                );
              } else if (index == 3) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  (route) => false,
                );
              } else if (index == 4) {
                if (authProvider.isAdmin) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AdminOrdersScreen()),
                    (route) => false,
                  );
                } else if (authProvider.isAgent) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AgentDashboardScreen()),
                    (route) => false,
                  );
                }
              } else if (index == 5) {
                // Already on messages
                return;
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildConversationCard(
    BuildContext context,
    Conversation conversation,
    User otherUser,
    Message? lastMessage,
    MessagesProvider messagesProvider,
  ) {
    final isAdmin = otherUser.isAdmin;
    final unreadCount = conversation.unreadCount;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              conversation: conversation,
              otherUser: otherUser,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: isAdmin
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                isAdmin ? Icons.admin_panel_settings : Icons.person,
                color: isAdmin
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          otherUser.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lastMessage != null)
                        Text(
                          _formatTime(lastMessage.timestamp),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage?.content ?? 'No messages yet',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: unreadCount > 0
                                ? Theme.of(context).textTheme.titleMedium?.color
                                : Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).cardColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _showNewConversationDialog(BuildContext context, String currentUserId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start New Conversation', style: Theme.of(context).textTheme.titleLarge),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: DummyUsers.users.where((u) => u.id != currentUserId).length,
            itemBuilder: (context, index) {
              final users = DummyUsers.users.where((u) => u.id != currentUserId).toList();
              if (index >= users.length) return const SizedBox.shrink();
              final user = users[index];
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: user.isAdmin
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(user.name),
                subtitle: user.isAdmin ? const Text('Admin') : Text(user.email),
                onTap: () {
                  Navigator.pop(context);
                  final conversationId = DummyMessages.getConversationId(currentUserId, user.id);
                  final conversation = Conversation(
                    id: conversationId,
                    participant1Id: currentUserId,
                    participant2Id: user.id,
                  );
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailScreen(
                        conversation: conversation,
                        otherUser: user,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  final Conversation conversation;
  final User otherUser;

  const ChatDetailScreen({
    super.key,
    required this.conversation,
    required this.otherUser,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final messagesProvider = Provider.of<MessagesProvider>(context, listen: false);
      messagesProvider.loadMessages(widget.conversation.id);
      // Mark as read when opening the thread (for the current user)
      if (authProvider.currentUser != null) {
        messagesProvider.markAsRead(widget.conversation.id, authProvider.currentUser!.id);
        messagesProvider.loadConversations(authProvider.currentUser!.id);
      }
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: widget.otherUser.isAdmin
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                widget.otherUser.isAdmin ? Icons.admin_panel_settings : Icons.person,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUser.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (widget.otherUser.isAdmin)
                    Text(
                      'Admin',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Consumer2<AuthProvider, MessagesProvider>(
      builder: (context, authProvider, messagesProvider, _) {
        if (authProvider.currentUser == null) {
          return const Center(child: Text('Not logged in'));
        }

        final currentUserId = authProvider.currentUser!.id;
        final messages = messagesProvider.currentMessages;
        
        // Reload messages if conversation changed
        if (messagesProvider.currentConversationId != widget.conversation.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            messagesProvider.loadMessages(widget.conversation.id);
          });
        }

          return Column(
            children: [
              // Messages list
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start the conversation!',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMe = message.senderId == currentUserId;
                          return _buildMessageBubble(context, message, isMe);
                        },
                      ),
              ),
              // Input area
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).scaffoldBackgroundColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: messagesProvider.isLoading
                            ? null
                            : () => _sendMessage(
                                  context,
                                  authProvider.currentUser!.id,
                                  widget.otherUser.id,
                                  messagesProvider,
                                ),
                        icon: Icon(Icons.send),
                        color: Theme.of(context).colorScheme.primary,
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, Message message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isMe
                    ? Theme.of(context).cardColor
                    : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isMe
                    ? Theme.of(context).cardColor.withOpacity(0.7)
                    : Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _sendMessage(
    BuildContext context,
    String senderId,
    String receiverId,
    MessagesProvider messagesProvider,
  ) async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    await messagesProvider.sendMessage(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
    );
    
    // Reload messages to ensure UI updates
    await messagesProvider.loadMessages(widget.conversation.id);
    await messagesProvider.markAsRead(widget.conversation.id, senderId);
    await messagesProvider.loadConversations(senderId);
    _scrollToBottom();
  }
}
