import 'package:flutter/material.dart';
import 'package:roomie/home/home_page.dart';
import 'package:roomie/home/createroom_page.dart';
import 'package:roomie/settings/settings_page.dart';

/// Main navigation wrapper with bottom navigation bar
/// This is the root widget that manages navigation between the three main tabs
/// Uses IndexedStack to keep all pages in memory for better performance
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  // Tracks which tab is currently selected (0=Home, 1=Create, 2=Settings)
  int _currentIndex = 0;

  // List of all pages that correspond to each tab
  // IndexedStack keeps all pages in memory and just shows/hides them
  final List<Widget> _pages = [
    HomePage(), // Tab 0: Browse and search rooms
    CreateRoomPage(), // Tab 1: Create new rooms
    SettingsPage(), // Tab 2: User profile and account management
  ];

  /// Public method to change the current tab
  /// This allows other widgets to programmatically switch tabs
  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack shows only the page at _currentIndex
      // This keeps all pages in memory for instant switching
      body: IndexedStack(index: _currentIndex, children: _pages),

      // Custom bottom navigation bar with Instagram-style design
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          // Top border to separate from content
          border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
          // Subtle shadow for depth
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, -2), // Shadow above the bar
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Home tab button
                _buildNavItem(
                  icon: Icons.home_outlined, // Inactive icon
                  activeIcon: Icons.home, // Active icon (filled)
                  label: "Home", // Tab label
                  index: 0, // Tab index
                ),
                // Create tab button
                _buildNavItem(
                  icon: Icons.add_circle_outline, // Inactive icon
                  activeIcon: Icons.add_circle, // Active icon (filled)
                  label: "Create", // Tab label
                  index: 1, // Tab index
                ),
                // Settings tab button
                _buildNavItem(
                  icon: Icons.settings_outlined, // Inactive icon
                  activeIcon: Icons.settings, // Active icon (filled)
                  label: "Settings", // Tab label
                  index: 2, // Tab index
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds individual navigation item with active/inactive states
  /// Each tab has different icons for active and inactive states
  /// Active tabs have black color and background highlight
  Widget _buildNavItem({
    required IconData icon, // Icon shown when tab is inactive
    required IconData activeIcon, // Icon shown when tab is active
    required String label, // Text label below icon
    required int index, // Index of this tab (0, 1, or 2)
  }) {
    // Check if this tab is currently selected
    final isActive = _currentIndex == index;

    return GestureDetector(
      // Handle tap to switch tabs
      onTap: () {
        setState(() {
          _currentIndex = index; // Update selected tab
        });
      },
      child: Container(
        // Padding around the icon and text
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // Active tabs get a subtle black background
          color: isActive ? Colors.black.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon that changes based on active state
            Icon(
              isActive ? activeIcon : icon, // Show filled icon if active
              color: isActive
                  ? Colors.black
                  : Colors.grey[600], // Black if active
              size: 24,
            ),
            SizedBox(height: 4), // Small gap between icon and text
            // Tab label text
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive
                    ? FontWeight.w600
                    : FontWeight.normal, // Bold if active
                color: isActive
                    ? Colors.black
                    : Colors.grey[600], // Black if active
              ),
            ),
          ],
        ),
      ),
    );
  }
}
