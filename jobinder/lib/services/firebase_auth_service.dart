import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';

/// Implementation of AuthService using Firebase Authentication
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  /// Returns a stream of authentication state changes, allowing the app to react to user sign-in and sign-out events.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  /// Signs in a user with the provided email and password.
  /// Returns null if successful, or an error message if failed.
  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return e.toString();
    }
  }

  @override
  /// Creates a new user account with the provided email and password.
  /// Returns null if successful, or an error message if failed.
  Future<String?> registerWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return e.toString();
    }
  }

  @override
  /// Signs out the current user.
  /// Returns null if successful, or an error message if failed.
  Future<String?> signOut() async {
    try {
      await _auth.signOut();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Handles FirebaseAuthException and returns a user-friendly error message to display to the user.
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
}
