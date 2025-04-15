import 'package:otomoto/auth/errors/auth_exceptions.dart';
import 'package:otomoto/auth/services/auth_repository.dart';
import 'package:otomoto/auth/services/user_repository.dart';
import 'package:otomoto/auth/services/session_manager.dart';
import 'package:otomoto/core/models/user_model.dart';

class AuthService {
  final AuthRepository _authRepo;
  final UserRepository _userRepo;
  final SessionManager _sessionManager;

  AuthService(this._authRepo, this._userRepo, this._sessionManager);

  Future<UserModel?> authenticateUser(String cred, String password,
      {required bool isAdmin}) async {
    final user = await _authRepo.signInWithCredential(cred, password);
    if (user == null) throw InvalidCredentialsException();

    final userData = await _userRepo.getUserByEmail(user.email);
    if (userData == null) throw UserNotFoundException();

    if (isAdmin && !userData.roles.contains(1)) {
      await _authRepo.signOut();
      throw PermissionDeniedException();
    }

    if (!isAdmin && userData.roles.contains(1)) {
      await _authRepo.signOut();
      throw UnexpectedRoleException();
    }

    await _userRepo.updateLastLogin(userData.id);
    await _sessionManager.saveUser(userData.copyWith(uid: user.uid));

    return userData.copyWith(uid: user.uid);
  }

  Future<void> logOut() async {
    await _sessionManager.clearUser();
    await _authRepo.signOut();
  }

  Future<UserModel?> validateCurrentUser() async {
    final user = _authRepo.getCurrentUser();
    if (user == null) return null;

    try {
      await _authRepo.refreshToken();
      final userData = await _userRepo.getUserByEmail(user.email);
      if (userData == null) throw UserNotFoundException();
      if (userData.status != 'active') throw InactiveUserException();
      return userData.copyWith(uid: user.uid);
    } catch (_) {
      await _authRepo.signOut();
      return null;
    }
  }

  Future<bool> hasAdminRole() async {
    final user = _authRepo.getCurrentUser();
    final userData = await _userRepo.getUserByEmail(user?.email);
    return userData?.roles.contains(1) ?? false;
  }
}
