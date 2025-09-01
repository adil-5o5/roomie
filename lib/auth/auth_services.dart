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
      return null;
    }
  }

  //google in sign in
  Future<User?> googleSignIn() async {
    try {
      //trigger google sign in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; //user cancelled sign-in

      //get google authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      //create firebase credential using google tokens
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      //sign in with firebase using google credentials
      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Google-Sign In failed";
      return null;
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
  Future<User?> resetpassword(String email) async {
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
