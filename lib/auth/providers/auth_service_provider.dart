import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otomoto/auth/services/auth_service.dart';
import 'package:otomoto/auth/services/auth_repository.dart';
import 'package:otomoto/auth/services/user_repository.dart';
import 'package:otomoto/auth/services/session_manager.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  final authRepo = AuthRepository(auth, firestore);
  final userRepo = UserRepository(firestore);
  final sessionManager = SessionManager();

  return AuthService(authRepo, userRepo, sessionManager);
});
