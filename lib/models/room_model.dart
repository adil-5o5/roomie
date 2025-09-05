import 'package:cloud_firestore/cloud_firestore.dart';

/// Room data model for Firestore
/// This class represents a chat room with all its properties and metadata
/// Used throughout the app to handle room data consistently
///
/// Key features:
/// - Immutable data structure for consistency
/// - Firestore serialization/deserialization
/// - Copy with method for updates
/// - Member management for join/leave functionality
class RoomModel {
  final String id; // Unique identifier from Firestore document ID
  final String title; // Room title displayed in UI
  final String description; // Room description for details
  final int membersCount; // Maximum number of members allowed
  final List<String> keywords; // Search keywords for filtering rooms
  final String createdBy; // User ID of the room creator
  final DateTime createdAt; // Timestamp when room was created
  final List<String> members; // List of user IDs who joined the room

  RoomModel({
    required this.id,
    required this.title,
    required this.description,
    required this.membersCount,
    required this.keywords,
    required this.createdBy,
    required this.createdAt,
    this.members = const [],
  });

  /// Converts RoomModel to Map for saving to Firestore
  /// This method serializes the room data into a format that Firestore can store
  /// Handles DateTime conversion to Timestamp for proper Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'membersCount': membersCount,
      'keywords': keywords,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(
        createdAt,
      ), // Convert DateTime to Firestore Timestamp
      'members': members,
    };
  }

  /// Creates RoomModel from Firestore document data
  /// This factory constructor deserializes Firestore data back into RoomModel
  /// Handles null safety and type conversion from Firestore types
  ///
  /// Parameters:
  /// - id: Document ID from Firestore
  /// - map: Document data from Firestore
  factory RoomModel.fromMap(String id, Map<String, dynamic> map) {
    return RoomModel(
      id: id,
      title: map['title'] ?? '', // Default to empty string if null
      description: map['description'] ?? '',
      membersCount: map['membersCount'] ?? 0, // Default to 0 if null
      keywords: List<String>.from(
        map['keywords'] ?? [],
      ), // Convert to String list
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp)
          .toDate(), // Convert Firestore Timestamp to DateTime
      members: List<String>.from(
        map['members'] ?? [],
      ), // Convert to String list
    );
  }

  /// Create a copy of RoomModel with updated fields
  RoomModel copyWith({
    String? id,
    String? title,
    String? description,
    int? membersCount,
    List<String>? keywords,
    String? createdBy,
    DateTime? createdAt,
    List<String>? members,
  }) {
    return RoomModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      membersCount: membersCount ?? this.membersCount,
      keywords: keywords ?? this.keywords,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
    );
  }
}
