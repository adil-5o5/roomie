import 'package:flutter/material.dart';
import 'package:roomie/theme/app_theme.dart';

class RoomTile extends StatelessWidget {
  const RoomTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppTheme.glassmorphicCardDecoration,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Room icon with gradient
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(
                      AppTheme.glassBorderRadius,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryOrange.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 0,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.meeting_room,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: 20),
                // Room info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Python Developer Room",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Looking for Python developers to join our team",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Additional details
            Row(
              children: [
                // Location
                SizedBox(width: 0),
                // People count
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.warningYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.warningYellow.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: AppTheme.warningYellow,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "2 people",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.warningYellow,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                // View Details button
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(
                      AppTheme.glassBorderRadius,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryOrange.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to room details
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.glassBorderRadius,
                        ),
                      ),
                    ),
                    child: Text(
                      "Join Room",
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
    );
  }
}
