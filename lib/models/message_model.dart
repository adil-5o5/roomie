import 'package:cloud_firestore/cloud_firestore.dart';

/// Message data model for Firestore
/// This class represents a chat message with all its properties and metadata
/// Used in the chat system to handle message data consistently
///
/// Key features:
/// - Immutable data structure for consistency
/// - Firestore serialization/deserialization
/// - Support for text, images, and links
/// - User identification and timestamp tracking
/// - Helper methods for message type checking
class MessageModel {
  final String id; // Unique identifier from Firestore document ID
  final String text; // The actual message text content
  final String senderId; // User ID of who sent the message
  final String senderName; // Display name of the sender
  final DateTime timestamp; // When the message was sent
  final String? imageUrl; // Optional image URL from Firebase Storage
  final String? link; // Optional link if message contains a URL

  MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    this.imageUrl,
    this.link,
  });

  /// Convert MessageModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': Timestamp.fromDate(timestamp),
      'imageUrl': imageUrl,
      'link': link,
    };
  }

  /// Create MessageModel from Firestore document
  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      text: map['text'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'],
      link: map['link'],
    );
  }

  /// Checks if message contains a link
  /// Returns true if link field is not null and not empty
  /// Used in UI to determine if link preview should be shown
  bool get hasLink => link != null && link!.isNotEmpty;

  /// Checks if message has an image
  /// Returns true if imageUrl field is not null and not empty
  /// Used in UI to determine if image should be displayed
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Checks if message is from the current user
  /// Used in UI to determine message bubble styling (sent vs received)
  ///
  /// Parameters:
  /// - currentUserId: The ID of the currently logged-in user
  ///
  /// Returns: true if message was sent by current user
  bool isFromUser(String currentUserId) {
    return senderId == currentUserId;
  }
}
