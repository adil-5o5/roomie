import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roomie/models/room_model.dart';
import 'package:roomie/services/room_service.dart';
import 'package:roomie/home/chat_page.dart';

/// Room detail page that shows room information and allows users to join
/// Displays room title, description, member count, and join/leave functionality
class RoomDetailPage extends StatefulWidget {
  final String roomId;

  const RoomDetailPage({super.key, required this.roomId});

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  final RoomService _roomService = RoomService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isJoining = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<RoomModel?>(
          future: _roomService.getRoom(widget.roomId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            }

            if (snapshot.hasError || snapshot.data == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    SizedBox(height: 16),
                    Text(
                      "Room not found",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "This room may have been deleted or doesn't exist.",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("Go Back"),
                    ),
                  ],
                ),
              );
            }

            final room = snapshot.data!;
            return _buildRoomDetail(room);
          },
        ),
      ),
    );
  }

  /// Build the room detail UI with room information and join button
  Widget _buildRoomDetail(RoomModel room) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with back button
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: Colors.black),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Room Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                room.title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12),
              FutureBuilder<String>(
                future: _getUsername(room.createdBy),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      "Created by loading...",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    );
                  }
                  return Text(
                    "Created by @${snapshot.data ?? 'Unknown'}",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  );
                },
              ),
            ],
          ),

          SizedBox(height: 32),

          // Room Info Card
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  room.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 24),

                // Room Stats
                Row(
                  children: [
                    _buildStatItem(
                      icon: Icons.people_outline,
                      label: "Members",
                      value: "${room.members.length}",
                    ),
                    SizedBox(width: 32),
                    _buildStatItem(
                      icon: Icons.group_add,
                      label: "Max Members",
                      value: "${room.membersCount}",
                    ),
                  ],
                ),

                // Keywords
                if (room.keywords.isNotEmpty) ...[
                  SizedBox(height: 24),
                  Text(
                    "Keywords",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: room.keywords.map((keyword) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          keyword,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 32),

          // Join/Leave Room Button
          FutureBuilder<bool>(
            future: _roomService.isUserInRoom(room.id),
            builder: (context, membershipSnapshot) {
              if (membershipSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return SizedBox(
                  height: 56,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                );
              }

              final isUserInRoom = membershipSnapshot.data ?? false;
              // Room is full when members (excluding owner) reach the limit
              // Owner is not counted as a member, so they don't take up a slot
              final isRoomFull = room.members.length >= room.membersCount;
              final isOwner = room.createdBy == _auth.currentUser?.uid;

              // Don't show join/leave button for room owners
              if (isOwner) {
                return SizedBox(
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Text(
                        "You own this room",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isJoining || (isRoomFull && !isUserInRoom)
                      ? null
                      : () => _handleJoinLeave(room.id, isUserInRoom),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUserInRoom ? Colors.red : Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isJoining
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          isRoomFull && !isUserInRoom
                              ? "Room Full"
                              : isUserInRoom
                              ? "Leave Room"
                              : "Join Room",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              );
            },
          ),

          // Enter Chat Button (only if user is in room)
          FutureBuilder<bool>(
            future: _roomService.isUserInRoom(room.id),
            builder: (context, membershipSnapshot) {
              if (membershipSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return SizedBox.shrink();
              }

              final isUserInRoom = membershipSnapshot.data ?? false;

              if (!isUserInRoom) return SizedBox.shrink();

              return Column(
                children: [
                  SizedBox(height: 16),
                  SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => _enterChat(room),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Enter Chat",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build a stat item widget for room information
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  /// Handle joining or leaving a room
  void _handleJoinLeave(String roomId, bool isUserInRoom) async {
    setState(() {
      _isJoining = true;
    });

    try {
      bool success;
      if (isUserInRoom) {
        success = await _roomService.leaveRoom(roomId);
      } else {
        success = await _roomService.joinRoom(roomId);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isUserInRoom
                  ? "Left room successfully"
                  : "Joined room successfully",
            ),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Refresh the UI
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to ${isUserInRoom ? 'leave' : 'join'} room"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Join limit reached')) {
        errorMessage = "Join limit reached. Try again next week.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() {
        _isJoining = false;
      });
    }
  }

  /// Get username from user ID
  /// Fetches the username from Firestore users collection
  Future<String> _getUsername(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        return userData?['username'] ?? 'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      print('Error fetching username: $e');
      return 'Unknown';
    }
  }

  /// Navigate to chat page for the room
  void _enterChat(RoomModel room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(roomId: room.id, roomTitle: room.title),
      ),
    );
  }
}
