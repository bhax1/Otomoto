import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otomoto/core/utils/validators.dart';

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository(this.auth, this.firestore);

  /// Sign in using either email or username
  Future<User?> signInWithCredential(String credential, String password) async {
    if (Validators.isValidEmail(credential)) {
      // Login with email
      return (await auth.signInWithEmailAndPassword(
        email: credential,
        password: password,
      ))
          .user;
    }

    // Otherwise, resolve username to email
    final query = await firestore
        .collection('staff')
        .where('username', isEqualTo: credential)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final email = query.docs.first['email'];
    return (await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ))
        .user;
  }

  /// Get currently signed in user
  User? getCurrentUser() => auth.currentUser;

  /// Refresh user token
  Future<void> refreshToken() async {
    final user = auth.currentUser;
    if (user != null) {
      await user.getIdToken(true);
    }
  }

  /// Sign out from Firebase
  Future<void> signOut() async {
    await auth.signOut();
  }
}
