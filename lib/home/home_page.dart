import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roomie/widgets/roomtile.dart';
import 'package:roomie/models/room_model.dart';
import 'package:roomie/services/room_service.dart';
import 'package:roomie/navigation/main_navigation.dart';
import 'room_detail_page.dart';

/// Home page that displays a list of available rooms for users to browse and join
/// Features:
/// - Real-time room list from Firestore
/// - Search functionality to filter rooms
/// - Excludes rooms created by the current user
/// - Navigation to room details and creation
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controller for the search input field
  final TextEditingController _searchController = TextEditingController();

  // Service class that handles all room-related Firestore operations
  final RoomService _roomService = RoomService();

  // Firebase Auth instance to get current user information
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current search query string
  String _searchQuery = '';

  @override
  void dispose() {
    // Clean up the search controller to prevent memory leaks
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "H O M E",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Bar - allows users to filter rooms by title, description, or keywords
              TextField(
                controller:
                    _searchController, // Controller to manage text input
                decoration: InputDecoration(
                  hintText: "Search for rooms...", // Placeholder text
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                  ), // Grey placeholder
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[500],
                  ), // Search icon
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[500],
                    ), // Clear button
                    onPressed: () {
                      _searchController.clear(); // Clear the text field
                      setState(() {
                        _searchQuery = ''; // Reset search query
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                    ), // Grey border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                    ), // Grey border when not focused
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2,
                    ), // Black border when focused
                  ),
                  filled: true,
                  fillColor: Colors.white, // White background
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
                onChanged: (value) {
                  // Update search query in real-time as user types
                  setState(() {
                    _searchQuery = value
                        .toLowerCase(); // Convert to lowercase for case-insensitive search
                  });
                },
              ),

              SizedBox(height: 20),

              // Rooms List with StreamBuilder - displays real-time room data from Firestore
              Expanded(
                child: StreamBuilder<List<RoomModel>>(
                  stream: _roomService
                      .getRoomsStream(), // Stream of all rooms from Firestore
                  builder: (context, snapshot) {
                    // Show loading indicator while data is being fetched
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      );
                    }

                    // Show error state if something went wrong
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[400], // Red error icon
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Error loading rooms",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              snapshot.error
                                  .toString(), // Show actual error message
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    // Get all rooms from Firestore
                    final allRooms = snapshot.data ?? [];
                    final currentUserId =
                        _auth.currentUser?.uid; // Get current user's ID

                    // Filter rooms based on search query and exclude user's own rooms
                    final filteredRooms = allRooms.where((room) {
                      // Exclude rooms created by current user (they can't join their own rooms)
                      if (room.createdBy == currentUserId) return false;

                      // Apply search filter if user has entered a search query
                      if (_searchQuery.isEmpty)
                        return true; // Show all rooms if no search

                      // Search in title, description, and keywords
                      return room.title.toLowerCase().contains(_searchQuery) ||
                          room.description.toLowerCase().contains(
                            _searchQuery,
                          ) ||
                          room.keywords.any(
                            (keyword) =>
                                keyword.toLowerCase().contains(_searchQuery),
                          );
                    }).toList();

                    if (filteredRooms.isEmpty && _searchQuery.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              "No rooms found",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Try searching with different keywords",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (filteredRooms.isEmpty) {
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
                              "No rooms yet",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Create the first room to get started!",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // Results count
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${filteredRooms.length} rooms found",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Rooms List
                        Expanded(
                          child: ListView.builder(
                            itemCount: filteredRooms.length,
                            itemBuilder: (context, index) {
                              final room = filteredRooms[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: RoomTile(
                                  title: room.title,
                                  description: room.description,
                                  peopleCount: room.members.length,
                                  onTap: () => _navigateToRoomDetail(room),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the Create tab in main navigation
          // This ensures consistent navigation flow
          final mainNav = context
              .findAncestorStateOfType<MainNavigationState>();
          if (mainNav != null) {
            mainNav.changeTab(1); // Switch to Create tab (index 1)
          }
        },
        backgroundColor: Colors.black,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: "Add New Room",
      ),
    );
  }

  /// Navigate to room detail page when a room tile is tapped
  void _navigateToRoomDetail(RoomModel room) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RoomDetailPage(roomId: room.id)),
    );
  }
}
