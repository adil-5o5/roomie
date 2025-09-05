import 'package:cloud_firestore/cloud_firestore.dart';

/// Room data model for Firestore
/// Represents a chat room with basic information and metadata
class RoomModel {
  final String id;
  final String title;
  final String description;
  final int membersCount;
  final List<String> keywords;
  final String createdBy;
  final DateTime createdAt;
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

  /// Convert RoomModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'membersCount': membersCount,
      'keywords': keywords,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'members': members,
    };
  }

  /// Create RoomModel from Firestore document
  factory RoomModel.fromMap(String id, Map<String, dynamic> map) {
    return RoomModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      membersCount: map['membersCount'] ?? 0,
      keywords: List<String>.from(map['keywords'] ?? []),
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      members: List<String>.from(map['members'] ?? []),
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
