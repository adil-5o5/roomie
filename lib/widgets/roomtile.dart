import 'package:flutter/material.dart';

/// Reusable widget that displays room information in a card format
/// This widget is used in the HomePage to show available rooms
///
/// Features:
/// - Clean card design with shadow and rounded corners
/// - Room title, description, and member count display
/// - Tap functionality to navigate to room details
/// - Consistent styling with app theme
///
/// Used in: HomePage room list
class RoomTile extends StatelessWidget {
  final String title; // Room title to display
  final String description; // Room description (truncated to 2 lines)
  final int peopleCount; // Number of people currently in the room
  final VoidCallback? onTap; // Callback function when tile is tapped

  const RoomTile({
    super.key,
    required this.title,
    required this.description,
    required this.peopleCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Make entire card tappable for better UX
      onTap: onTap,
      child: Container(
        width: double.infinity,
        // Card styling with shadow and rounded corners
        decoration: BoxDecoration(
          color: Colors.white, // White background
          borderRadius: BorderRadius.circular(16), // Rounded corners
          border: Border.all(color: Colors.grey[200]!), // Light grey border
          boxShadow: [
            // Subtle shadow for depth
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 2), // Shadow below the card
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 12),

              // Room Description
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 20),

              // Bottom Row with People Count and View Button
              Row(
                children: [
                  // People Count
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 6),
                      Text(
                        "$peopleCount people",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  Spacer(),

                  // View Room Button
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 0,
                        ),
                      ),
                      child: Text(
                        "View Room",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
