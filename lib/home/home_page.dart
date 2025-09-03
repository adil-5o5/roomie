import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:roomie/widgets/customappbar.dart';
import 'package:roomie/widgets/roomtile.dart';
import 'package:roomie/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _rooms = [
    {
      'title': 'Python Developer Room',
      'description': 'Looking for Python developers to join our team',
      'location': 'New York, NY',
      'price': '\$1500/month',
    },
    {
      'title': 'Frontend Developer Room',
      'description': 'Seeking frontend developers for web projects',
      'location': 'San Francisco, CA',
      'price': '\$1800/month',
    },
    {
      'title': 'Mobile App Developer Room',
      'description': 'Join our mobile app development team',
      'location': 'Austin, TX',
      'price': '\$1600/month',
    },
    {
      'title': 'Data Scientist Room',
      'description': 'Looking for data scientists and ML engineers',
      'location': 'Seattle, WA',
      'price': '\$2000/month',
    },
    {
      'title': 'DevOps Engineer Room',
      'description': 'Seeking DevOps engineers for infrastructure',
      'location': 'Boston, MA',
      'price': '\$1700/month',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Custom App Bar
                Container(
                  decoration: AppTheme.glassmorphicDecoration,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.meeting_room,
                        color: AppTheme.primaryOrange,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "H O M E",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () {
                          // TODO: Add profile or settings functionality
                        },
                        icon: Icon(
                          Icons.person_outline,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Search Bar with glassmorphic effect
                Container(
                  decoration: AppTheme.glassmorphicCardDecoration,
                  padding: EdgeInsets.all(4),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: "Search for rooms...",
                      hintStyle: TextStyle(color: AppTheme.textSecondary),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppTheme.textSecondary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear, color: AppTheme.textSecondary),
                        onPressed: () => _searchController.clear(),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.glassBorderRadius,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.glassBorderRadius,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.glassBorderRadius,
                        ),
                        borderSide: BorderSide(
                          color: AppTheme.primaryOrange,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: AppTheme.lightGrey.withOpacity(0.1),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                    onChanged: (value) {
                      // TODO: Implement search functionality
                      setState(() {
                        // Filter rooms based on search
                      });
                    },
                  ),
                ),

                SizedBox(height: 20),

                // Results count
                Container(
                  decoration: AppTheme.glassmorphicDecoration,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    "${_rooms.length} rooms found",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Rooms List
                Expanded(
                  child: ListView.builder(
                    itemCount: _rooms.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: RoomTile(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.accentGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryOrange.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 0,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to add room page
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Add Room functionality coming soon!"),
                backgroundColor: AppTheme.accentBlue,
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.add, color: Colors.white),
          tooltip: "Add New Room",
        ),
      ),
    );
  }
}
