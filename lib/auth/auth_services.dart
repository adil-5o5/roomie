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

  //debug google sign in configuration
  Future<void> debugGoogleSignInConfig() async {
    try {
      print("🔍 Debugging Google Sign-In configuration...");
      print("📱 Package name: ${_googleSignIn.clientId}");
      print("🔑 Google Sign-In instance: $_googleSignIn");

      // Check if user is already signed in
      final isSignedIn = await _googleSignIn.isSignedIn();
      print("👤 User already signed in: $isSignedIn");

      if (isSignedIn) {
        final currentUser = await _googleSignIn.signInSilently();
        print("👤 Current Google user: ${currentUser?.email}");
      }

      print("✅ Google Sign-In configuration check completed");
    } catch (e) {
      print("❌ Error checking Google Sign-In configuration: $e");
    }
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
