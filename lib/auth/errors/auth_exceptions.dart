class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException() : super('Invalid email or password.');
}

class PermissionDeniedException extends AuthException {
  PermissionDeniedException()
      : super('Permission denied: Admin access required.');
}

class UnexpectedRoleException extends AuthException {
  UnexpectedRoleException()
      : super('Permission denied: Admins must log in through the admin portal');
}

class UserNotFoundException extends AuthException {
  UserNotFoundException() : super('User not found.');
}

class InactiveUserException extends AuthException {
  InactiveUserException() : super('Your account is inactive.');
}
