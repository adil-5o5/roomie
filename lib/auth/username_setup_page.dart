import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roomie/navigation/main_navigation.dart';

/// Username setup page that appears after successful authentication
/// This page is shown immediately after user signs up or logs in
/// Allows users to set a unique username with strict validation rules:
/// - 3-20 characters long
/// - Only lowercase letters, numbers, and underscores
/// - Must be unique across all users
/// - Can be skipped for later setup
class UsernameSetupPage extends StatefulWidget {
  const UsernameSetupPage({super.key});

  @override
  State<UsernameSetupPage> createState() => _UsernameSetupPageState();
}

class _UsernameSetupPageState extends State<UsernameSetupPage> {
  // Controller for the username input field
  final TextEditingController _usernameController = TextEditingController();

  // Firestore instance for database operations
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firebase Auth instance to get current user
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Loading state when saving username to database
  bool _isLoading = false;

  // Loading state when checking if username is available
  bool _isCheckingUsername = false;

  // Error message to display if username validation fails
  String? _usernameError;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  /// Validates username format according to app rules
  /// Rules: 3-20 characters, only lowercase letters, numbers, and underscores
  /// Returns true if username meets all requirements
  bool _isValidUsername(String username) {
    // Regular expression that matches only lowercase letters, numbers, and underscores
    final regex = RegExp(r'^[a-z0-9_]+$');

    // Check if username matches regex AND is within length limits
    return regex.hasMatch(username) &&
        username.length >= 3 &&
        username.length <= 20;
  }

  /// Checks if username is already taken by another user
  /// Queries Firestore users collection to see if username exists
  /// Returns true if username is available (not taken)
  Future<bool> _isUsernameAvailable(String username) async {
    try {
      // Query users collection for existing username
      final doc = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1) // Only need to check if at least one exists
          .get();

      // Return true if no documents found (username is available)
      return doc.docs.isEmpty;
    } catch (e) {
      print('Error checking username availability: $e');
      return false; // Return false on error to be safe
    }
  }

  /// Saves the username to user profile in Firestore
  /// This method handles the complete flow:
  /// 1. Validates username format
  /// 2. Checks if username is available
  /// 3. Saves to Firestore user document
  /// 4. Updates Firebase Auth display name
  /// 5. Navigates to main app
  Future<void> _saveUsername() async {
    // Get username from input field and normalize it
    final username = _usernameController.text.trim().toLowerCase();

    // Step 1: Validate username format
    if (!_isValidUsername(username)) {
      setState(() {
        _usernameError =
            "Username must be 3-20 characters, lowercase letters, numbers, and _ only";
      });
      return;
    }

    // Step 2: Show loading state while checking availability
    setState(() {
      _isCheckingUsername = true;
      _usernameError = null;
    });

    try {
      // Step 3: Check if username is available
      bool isAvailable = await _isUsernameAvailable(username);

      if (!isAvailable) {
        setState(() {
          _usernameError = "Username is already taken";
          _isCheckingUsername = false;
        });
        return;
      }

      // Step 4: Show confirmation dialog
      setState(() {
        _isCheckingUsername = false;
      });

      final confirmed = await _showUsernameConfirmationDialog(username);
      if (!confirmed) return;

      // Step 5: Show saving state
      setState(() {
        _isLoading = true;
      });

      // Step 6: Save username to user document in Firestore
      final user = _auth.currentUser;
      if (user != null) {
        // Create or update user document with username and profile info
        await _firestore.collection('users').doc(user.uid).set(
          {
            'username': username,
            'email': user.email,
            'displayName': user.displayName ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'role': 'Member', // Default role for new users
          },
          SetOptions(merge: true),
        ); // merge: true prevents overwriting existing data

        // Step 6: Update Firebase Auth display name for consistency
        await user.updateDisplayName(username);

        // Step 7: Navigate to main app navigation
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => MainNavigation()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      // Handle any errors during the save process
      setState(() {
        _usernameError = "Error saving username: $e";
        _isLoading = false;
        _isCheckingUsername = false;
      });
    }
  }

  /// Show confirmation dialog for username selection
  /// This warns users that username cannot be changed later
  Future<bool> _showUsernameConfirmationDialog(String username) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Confirm Username',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your username will be:',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      '@$username',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange[600],
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Username cannot be changed later. Please choose carefully.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose Your Username",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "This will be your unique identifier in the app",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),

              SizedBox(height: 40),

              // Username illustration
              Container(
                height: 120,
                child: Icon(
                  Icons.person_add,
                  size: 80,
                  color: Colors.grey[400],
                ),
              ),

              SizedBox(height: 40),

              // Username Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Username",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    textCapitalization: TextCapitalization.none,
                    decoration: InputDecoration(
                      hintText: "Enter your username",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: _isCheckingUsername
                          ? Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              ),
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _usernameError = null;
                      });
                    },
                  ),
                ],
              ),

              // Username Rules
              Container(
                margin: EdgeInsets.only(top: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Username Rules",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      "• 3-20 characters long\n• Lowercase letters only\n• Numbers and underscore allowed\n• No spaces or special symbols",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Error Message
              if (_usernameError != null) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _usernameError!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 32),

              // Continue Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading || _isCheckingUsername
                      ? null
                      : _saveUsername,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
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
                          "Continue",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 24),

              // Username is required notice
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Username is required to continue. It cannot be changed later.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
