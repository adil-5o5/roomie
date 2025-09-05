import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roomie/auth/signin_page.dart';
import 'package:roomie/auth/username_setup_page.dart';
import 'package:roomie/navigation/main_navigation.dart';

/// Authentication gateway that determines which screen to show based on user state
/// This is the main entry point that handles authentication flow like Instagram
class AuthGateway extends StatefulWidget {
  const AuthGateway({super.key});

  @override
  State<AuthGateway> createState() => _AuthGatewayState();
}

class _AuthGatewayState extends State<AuthGateway> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Loading state while checking authentication
  bool _isLoading = true;

  // Current user state
  User? _currentUser;
  bool _hasUsername = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  /// Check the current authentication state and user data
  /// This method determines which screen to show based on user's login status and profile completion
  Future<void> _checkAuthState() async {
    try {
      // Wait for Firebase Auth to initialize
      await Future.delayed(Duration(milliseconds: 500));

      // Get current user from Firebase Auth
      _currentUser = _auth.currentUser;

      if (_currentUser != null) {
        // User is logged in, check if they have a username set
        await _checkUserProfile();
      } else {
        // User is not logged in
        _hasUsername = false;
      }
    } catch (e) {
      print('❌ Error checking auth state: $e');
      _hasUsername = false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Check if the current user has a complete profile (username set)
  /// This determines if we need to show the username setup page
  Future<void> _checkUserProfile() async {
    try {
      if (_currentUser != null) {
        // Check if user document exists in Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          // Check if username is set and not empty
          _hasUsername =
              userData?['username'] != null &&
              userData!['username'].toString().isNotEmpty;
        } else {
          _hasUsername = false;
        }
      }
    } catch (e) {
      print('❌ Error checking user profile: $e');
      _hasUsername = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking authentication state
    if (_isLoading) {
      return _buildSplashScreen();
    }

    // Determine which screen to show based on authentication state
    if (_currentUser == null) {
      // User is not logged in, show sign in page
      return SigninPage();
    } else if (!_hasUsername) {
      // User is logged in but doesn't have username set, show username setup
      return UsernameSetupPage();
    } else {
      // User is logged in and has username, show main app
      return MainNavigation();
    }
  }

  /// Build the splash screen with loading animation
  /// This is shown while checking the user's authentication state
  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 60,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 32),

            // App name
            Text(
              'Roomie',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 8),

            // Tagline
            Text(
              'Connect with like-minded people',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            SizedBox(height: 48),

            // Loading indicator
            CircularProgressIndicator(color: Colors.black, strokeWidth: 2),

            SizedBox(height: 16),

            // Loading text
            Text(
              'Loading...',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
