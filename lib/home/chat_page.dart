import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roomie/models/message_model.dart';
import 'package:roomie/services/room_service.dart';

/// Chat page that displays real-time messages for a specific room
/// This page provides a complete chat experience with:
/// - Real-time message streaming from Firestore
/// - Message input with instant sending (no loading delays)
/// - Link detection and display
/// - Image support (placeholder for future implementation)
/// - Auto-scroll to new messages
/// - User identification with avatars
///
/// Messages are stored in Firestore subcollection: rooms/{roomId}/messages
class ChatPage extends StatefulWidget {
  final String roomId; // ID of the room to display messages for
  final String roomTitle; // Title of the room for display in app bar

  const ChatPage({super.key, required this.roomId, required this.roomTitle});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Controller for the message input field
  final TextEditingController _messageController = TextEditingController();

  // Service for handling room and message operations
  final RoomService _roomService = RoomService();

  // Firebase Auth instance to get current user info
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Controller for auto-scrolling to new messages
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.roomTitle,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "Tap to send message",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showRoomInfo,
            icon: Icon(Icons.info_outline, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _roomService.getMessagesStream(widget.roomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  );
                }

                if (snapshot.hasError) {
                  return Stack(
                    children: [
                      Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      ),
                    ],
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No messages yet",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Be the first to send a message!",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Auto-scroll to bottom when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser = message.isFromUser(
                      _auth.currentUser?.uid ?? '',
                    );
                    return _buildMessageBubble(message, isCurrentUser);
                  },
                );
              },
            ),
          ),

          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  /// Build a message bubble widget
  Widget _buildMessageBubble(MessageModel message, bool isCurrentUser) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Text(
                message.senderName.isNotEmpty
                    ? message.senderName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.black : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isCurrentUser)
                    Text(
                      message.senderName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  if (!isCurrentUser) SizedBox(height: 4),
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: isCurrentUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (message.hasImage) ...[
                    SizedBox(height: 8),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[300],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          message.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    color: Colors.grey[600],
                                    size: 32,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Failed to load image",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  if (message.hasLink) ...[
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isCurrentUser
                            ? Colors.white.withOpacity(0.1)
                            : Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCurrentUser
                              ? Colors.white.withOpacity(0.3)
                              : Colors.blue[200]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.link,
                            size: 16,
                            color: isCurrentUser
                                ? Colors.white
                                : Colors.blue[600],
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              message.link!,
                              style: TextStyle(
                                fontSize: 14,
                                color: isCurrentUser
                                    ? Colors.white
                                    : Colors.blue[600],
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: isCurrentUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black,
              child: Text(
                _auth.currentUser?.displayName?.isNotEmpty == true
                    ? _auth.currentUser!.displayName![0].toUpperCase()
                    : _auth.currentUser?.email?.isNotEmpty == true
                    ? _auth.currentUser!.email![0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build the message input widget
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // Message input field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 12),
          // Send button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  /// Sends a message to the room with instant feedback
  /// This method provides a smooth chat experience by:
  /// 1. Clearing input immediately (no loading delays)
  /// 2. Detecting and extracting links from message text
  /// 3. Sending to Firestore via RoomService
  /// 4. Showing error messages only if sending fails
  ///
  /// The message appears instantly in the UI due to real-time streaming
  void _sendMessage() async {
    // Get message text and validate
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Clear input immediately for better user experience
    // This makes the chat feel responsive and instant
    _messageController.clear();

    try {
      // Step 1: Detect if message contains a link
      String? link;
      final linkRegex = RegExp(r'https?://[^\s]+', caseSensitive: false);
      final match = linkRegex.firstMatch(text);
      if (match != null) {
        link = match.group(0); // Extract the full URL
      }

      // Step 2: Send message to Firestore via RoomService
      // No loading state needed - message appears instantly via StreamBuilder
      await _roomService.sendMessage(
        roomId: widget.roomId,
        text: text,
        link: link,
      );
    } catch (e) {
      // Step 3: Show error message only if sending fails
      // This is rare since we clear input immediately
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to send message: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Show room information dialog
  void _showRoomInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Room Info"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Room: ${widget.roomTitle}"),
            SizedBox(height: 8),
            Text("ID: ${widget.roomId}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  /// Format timestamp for display
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return "${difference.inDays}d ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m ago";
    } else {
      return "Just now";
    }
  }
}
