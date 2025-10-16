import 'package:flutter/material.dart';
import 'package:frontend/models/message.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final User recipient;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.recipient,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}


class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  late IO.Socket _socket;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _initSocket();
  }

  void _initSocket() {
    // Thay đổi URL nếu địa chỉ IP của bạn khác
    _socket = IO.io('http://192.168.1.11:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.connect();

    _socket.onConnect((_) {
      print('Socket connected');
      _socket.emit('joinRoom', widget.conversationId);
    });

    _socket.on('receiveMessage', (data) {
      final message = Message.fromJson(data);
      if (mounted) {
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
      }
    });

    _socket.onDisconnect((_) => print('Socket disconnected'));
  }

  Future<void> _fetchMessages() async {
    try {
      final messagesJson = await _apiService.getMessages(widget.conversationId);
      final messages = messagesJson.map((m) => Message.fromJson(m)).toList();
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load messages: $e')),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() { _isSending = true; });

    try {
      final sentMessage = await _apiService.addMessage(widget.conversationId, _messageController.text.trim());
      _socket.emit('sendMessage', {
        'conversationId': widget.conversationId,
        'message': sentMessage.toJson(), // Gửi toàn bộ object message
      });
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    } finally {
      if (mounted) setState(() { _isSending = false; });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipient.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(child: Text('No messages yet. Start the conversation!'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8.0),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          // Handle potential null senderId from old data
                          if (message.senderId.isEmpty) {
                             // Or return a placeholder widget
                            return const SizedBox.shrink();
                          }
                          final isMe = message.senderId == currentUserId;
                          return _buildMessageBubble(message, isMe);
                        },
                      ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: _isSending ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
            onPressed: _isSending ? null : _sendMessage,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}

extension MessageJson on Message {
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'conversationId': conversationId,
      'sender': senderId, // Backend mong đợi 'sender'
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
