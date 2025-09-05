// ignore_for_file: dead_code

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthServices {
  //instance of firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //stream to check user login status in real time
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  //sign up with email and password
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user; //return the signed up user.
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Sign Up failed";
    }
  }

  //sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user; //return the sign in user.
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Sign In failed";
    }
  }

  //check google sign in configuration
  Future<bool> isGoogleSignInAvailable() async {
    try {
      final isAvailable = await _googleSignIn.isSignedIn();
      print("🔍 Google Sign-In available: $isAvailable");
      return true;
    } catch (e) {
      print("❌ Google Sign-In not available: $e");
      return false;
    }
  }

  // Debug method to check Google Sign-In configuration
  Future<void> debugGoogleSignInConfig() async {
    print("🔍 Debugging Google Sign-In Configuration...");

    try {
      // Check if Google Play Services is available
      bool isAvailable = await _googleSignIn.isSignedIn();
      print("✅ Google Sign-In is available: $isAvailable");

      // Check current user
      GoogleSignInAccount? currentUser = _googleSignIn.currentUser;
      if (currentUser != null) {
        print("👤 Current Google user: ${currentUser.email}");
      } else {
        print("❌ No current Google user");
      }

      // Check if user can sign in
      bool canSignIn = await _googleSignIn.isSignedIn();
      print("🔐 Can sign in: $canSignIn");
    } catch (e) {
      print("❌ Error checking Google Sign-In config: $e");
    }

    print("📱 Package name: com.example.roomie");
    print("🔑 Make sure you have:");
    print("   1. Generated SHA-1 fingerprint for your app");
    print("   2. Added SHA-1 to Firebase Console");
    print("   3. Enabled Google Sign-In in Firebase Auth");
    print("   4. Updated google-services.json with real OAuth client ID");
  }

  //google in sign in
  Future<User?> googleSignIn() async {
    try {
      print("🔄 Starting Google Sign-In process...");

      //trigger google sign in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("❌ User cancelled Google Sign-In");
        return null; //user cancelled sign-in
      }

      print("✅ Google Sign-In successful for: ${googleUser.email}");

      //get google authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print("🔑 Got Google auth tokens");

      //create firebase credential using google tokens
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("🔐 Created Firebase credential");

      //sign in with firebase using google credentials
      UserCredential result = await _auth.signInWithCredential(credential);
      print("🎉 Firebase authentication successful: ${result.user?.email}");
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("❌ Firebase Auth Exception: ${e.code} - ${e.message}");
      throw e.message ?? "Google-Sign In failed";
    } on Exception catch (e) {
      print("❌ General Exception during Google Sign-In: $e");
      throw "Google Sign-In failed: ${e.toString()}";
    }
  }

  //logout
  Future<User?> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut(); //also logout from google
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "sign out failed";
    }
    return null;
  }

  //reset password
  Future<void> resetpassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Password reset email sent to $email");
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Reset password error";
    }
  }

  /// Delete user account and all associated data from Firestore
  /// This method performs a complete cleanup of user data
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      print(
        '🗑️ Starting comprehensive account deletion for user: ${user.uid}',
      );

      // Step 1: Delete all rooms created by the user
      await _deleteUserRooms(user.uid);

      // Step 2: Remove user from all rooms they're a member of
      await _removeUserFromAllRooms(user.uid);

      // Step 3: Delete all messages sent by the user
      await _deleteUserMessages(user.uid);

      // Step 4: Delete user document from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      print('✅ User document deleted from Firestore');

      // Step 5: Delete Firebase Auth user account
      await user.delete();
      print('✅ Firebase Auth user deleted');

      print('✅ Account deletion completed successfully');
    } catch (e) {
      print('❌ Delete account failed: $e');
      throw Exception('Failed to delete account: $e');
    }
  }

  /// Delete all rooms created by the user
  Future<void> _deleteUserRooms(String userId) async {
    try {
      print('🗑️ Deleting rooms created by user: $userId');

      // Get all rooms created by the user
      final roomsQuery = await _firestore
          .collection('rooms')
          .where('createdBy', isEqualTo: userId)
          .get();

      // Delete each room and its messages
      for (final roomDoc in roomsQuery.docs) {
        final roomId = roomDoc.id;
        print('🗑️ Deleting room: $roomId');

        // Delete all messages in this room
        final messagesQuery = await _firestore
            .collection('rooms')
            .doc(roomId)
            .collection('messages')
            .get();

        // Delete each message
        for (final messageDoc in messagesQuery.docs) {
          await messageDoc.reference.delete();
        }

        // Delete the room document
        await roomDoc.reference.delete();
      }

      print('✅ Deleted ${roomsQuery.docs.length} rooms created by user');
    } catch (e) {
      print('❌ Error deleting user rooms: $e');
      throw Exception('Failed to delete user rooms: $e');
    }
  }

  /// Remove user from all rooms they're a member of
  Future<void> _removeUserFromAllRooms(String userId) async {
    try {
      print('🗑️ Removing user from all rooms: $userId');

      // Get all rooms where user is a member
      final roomsQuery = await _firestore
          .collection('rooms')
          .where('members', arrayContains: userId)
          .get();

      // Remove user from each room
      for (final roomDoc in roomsQuery.docs) {
        await roomDoc.reference.update({
          'members': FieldValue.arrayRemove([userId]),
        });
      }

      print('✅ Removed user from ${roomsQuery.docs.length} rooms');
    } catch (e) {
      print('❌ Error removing user from rooms: $e');
      throw Exception('Failed to remove user from rooms: $e');
    }
  }

  /// Delete all messages sent by the user
  Future<void> _deleteUserMessages(String userId) async {
    try {
      print('🗑️ Deleting messages sent by user: $userId');

      // Get all rooms to check for user messages
      final roomsQuery = await _firestore.collection('rooms').get();

      int deletedMessages = 0;

      // Check each room for user messages
      for (final roomDoc in roomsQuery.docs) {
        final roomId = roomDoc.id;

        // Get all messages in this room sent by the user
        final messagesQuery = await _firestore
            .collection('rooms')
            .doc(roomId)
            .collection('messages')
            .where('senderId', isEqualTo: userId)
            .get();

        // Delete each message
        for (final messageDoc in messagesQuery.docs) {
          await messageDoc.reference.delete();
          deletedMessages++;
        }
      }

      print('✅ Deleted $deletedMessages messages sent by user');
    } catch (e) {
      print('❌ Error deleting user messages: $e');
      throw Exception('Failed to delete user messages: $e');
    }
  }
}
