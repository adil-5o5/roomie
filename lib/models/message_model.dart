import 'package:cloud_firestore/cloud_firestore.dart';

/// Message data model for Firestore
/// Represents a chat message with text, optional image, and metadata
class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
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

  /// Check if message contains a link
  bool get hasLink => link != null && link!.isNotEmpty;

  /// Check if message has an image
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Check if message is from current user
  bool isFromUser(String currentUserId) {
    return senderId == currentUserId;
  }
}
