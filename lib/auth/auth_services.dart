// ignore_for_file: dead_code

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  //instance of firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  //delete account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
      print("✅ Account deleted");
    } catch (e) {
      print("❌ Delete account failed: $e");
    }
  }
}
