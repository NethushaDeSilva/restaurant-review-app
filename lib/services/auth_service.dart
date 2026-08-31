import 'package:firebase_auth/firebase_auth.dart';

/// All Firebase Authentication calls live here so the screens stay focused
/// on layout. Everything is static because there is only ever one signed-in
/// user and no state to keep.
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fires every time the user signs in or out. main.dart listens to this
  /// to decide whether to show the login screen or the app.
  static Stream<User?> authChanges() {
    return _auth.authStateChanges();
  }

  static User? get currentUser => _auth.currentUser;

  static Future<void> register(
    String name,
    String email,
    String password,
  ) async {
    final UserCredential credential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);
    // Store the name on the account so reviews can show who wrote them.
    await credential.user?.updateDisplayName(name);
    await credential.user?.reload();
  }

  static Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Firebase returns codes like 'wrong-password'. Showing those to a user
  /// is unhelpful, so they are translated into plain sentences here.
  static String messageFor(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Check your network and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a moment and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
