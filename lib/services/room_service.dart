import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/room_model.dart';
import '../models/message_model.dart';

/// Service class for handling all room-related Firestore operations
/// This is the central service that manages:
/// - Room creation and data persistence
/// - Real-time room data streaming
/// - User join/leave functionality with limits
/// - Message sending and real-time chat
/// - Room membership management
///
/// All methods handle authentication, error handling, and data validation
class RoomService {
  // Firestore instance for database operations
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firebase Auth instance for user authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Creates a new room in Firestore with all required data
  /// This method:
  /// 1. Validates user authentication
  /// 2. Creates room document with creator as first member
  /// 3. Saves to 'rooms' collection with auto-generated ID
  /// 4. Returns the room ID for further operations
  ///
  /// Parameters:
  /// - title: Room title (required)
  /// - description: Room description (required)
  /// - membersCount: Maximum number of members allowed
  /// - keywords: List of search keywords for the room
  ///
  /// Returns: Room ID as string
  Future<String> createRoom({
    required String title,
    required String description,
    required int membersCount,
    required List<String> keywords,
  }) async {
    try {
      // Step 1: Check if user is authenticated
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Step 2: Prepare room data structure
      final roomData = {
        'title': title,
        'description': description,
        'membersCount': membersCount,
        'keywords': keywords,
        'createdBy': user.uid, // Track who created the room
        'createdAt':
            FieldValue.serverTimestamp(), // Server timestamp for consistency
        'members':
            [], // Owner is not counted as a member - they have special privileges
      };

      // Step 3: Save room to Firestore and get document reference
      final docRef = await _firestore.collection('rooms').add(roomData);

      print('✅ Room created successfully with ID: ${docRef.id}');
      print('🔍 Room created by user: ${user.uid}');
      print('🔍 Room data: $roomData');
      return docRef.id; // Return room ID for navigation/updates
    } catch (e) {
      print('❌ Error creating room: $e');
      throw Exception('Failed to create room: $e');
    }
  }

  /// Get stream of all rooms from Firestore
  /// Returns real-time updates when rooms are added/modified
  Stream<List<RoomModel>> getRoomsStream() {
    return _firestore
        .collection('rooms')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return RoomModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  /// Get a specific room by ID
  /// Returns room data or null if not found
  Future<RoomModel?> getRoom(String roomId) async {
    try {
      final doc = await _firestore.collection('rooms').doc(roomId).get();
      if (doc.exists) {
        return RoomModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Error getting room: $e');
      return null;
    }
  }

  /// Join a room by adding user to members list
  /// Updates the room document with new member and checks join limits
  Future<bool> joinRoom(String roomId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check if user has reached join limit (2 rooms per week)
      bool canJoin = await _checkJoinLimit(user.uid);
      if (!canJoin) {
        throw Exception('Join limit reached. Try again next week.');
      }

      // Add user to room members
      await _firestore.collection('rooms').doc(roomId).update({
        'members': FieldValue.arrayUnion([user.uid]),
      });

      // Record join activity for limit tracking
      await _recordJoinActivity(user.uid, roomId);

      print('✅ User joined room: $roomId');
      return true;
    } catch (e) {
      print('❌ Error joining room: $e');
      return false;
    }
  }

  /// Check if user has reached the weekly join limit (2 rooms per week)
  Future<bool> _checkJoinLimit(String userId) async {
    try {
      final weekAgo = DateTime.now().subtract(Duration(days: 7));

      final query = await _firestore
          .collection('user_joins')
          .where('userId', isEqualTo: userId)
          .where('joinedAt', isGreaterThan: Timestamp.fromDate(weekAgo))
          .get();

      return query.docs.length < 2;
    } catch (e) {
      print('Error checking join limit: $e');
      return true; // Allow join if check fails
    }
  }

  /// Record join activity for limit tracking
  Future<void> _recordJoinActivity(String userId, String roomId) async {
    try {
      await _firestore.collection('user_joins').add({
        'userId': userId,
        'roomId': roomId,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error recording join activity: $e');
    }
  }

  /// Leave a room by removing user from members list
  /// Updates the room document to remove member
  Future<bool> leaveRoom(String roomId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Remove user from room members
      await _firestore.collection('rooms').doc(roomId).update({
        'members': FieldValue.arrayRemove([user.uid]),
      });

      print('✅ User left room: $roomId');
      return true;
    } catch (e) {
      print('❌ Error leaving room: $e');
      return false;
    }
  }

  /// Check if current user is a member of the room
  /// Returns true if user is the owner OR in the room's members list
  Future<bool> isUserInRoom(String roomId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final room = await getRoom(roomId);
      if (room == null) return false;

      // User is in room if they are the owner OR a member
      return room.createdBy == user.uid || room.members.contains(user.uid);
    } catch (e) {
      print('❌ Error checking room membership: $e');
      return false;
    }
  }

  /// Send a message to a room
  /// Creates a new message document in the room's messages subcollection
  Future<bool> sendMessage({
    required String roomId,
    required String text,
    String? imageUrl,
    String? link,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create message data
      final messageData = {
        'text': text,
        'senderId': user.uid,
        'senderName':
            user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous',
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
        'link': link,
      };

      // Add message to room's messages subcollection
      await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .add(messageData);

      print('✅ Message sent to room: $roomId');
      return true;
    } catch (e) {
      print('❌ Error sending message: $e');
      return false;
    }
  }

  /// Get stream of messages for a specific room
  /// Returns real-time updates when new messages are added
  Stream<List<MessageModel>> getMessagesStream(String roomId) {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MessageModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  /// Delete a room (only creator can delete)
  /// Removes the room document and all its messages
  Future<bool> deleteRoom(String roomId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final room = await getRoom(roomId);
      if (room == null) throw Exception('Room not found');
      if (room.createdBy != user.uid)
        throw Exception('Only room creator can delete');

      // Delete all messages first
      final messagesSnapshot = await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .get();

      for (var doc in messagesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the room document
      await _firestore.collection('rooms').doc(roomId).delete();

      print('✅ Room deleted: $roomId');
      return true;
    } catch (e) {
      print('❌ Error deleting room: $e');
      return false;
    }
  }
}
