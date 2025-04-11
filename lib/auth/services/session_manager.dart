import 'package:otomoto/core/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', user.id);
    await prefs.setString('userUid', user.uid);
    await prefs.setString('userEmail', user.email);
    await prefs.setString('username', user.username);
    await prefs.setString('name', user.name);
    await prefs.setStringList(
        'roles', user.roles.map((e) => e.toString()).toList());
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString('userId');
    final userUid = prefs.getString('userUid');
    final userEmail = prefs.getString('userEmail');
    final username = prefs.getString('username');
    final name = prefs.getString('name');
    final status = prefs.getString('status');
    final rolesStringList = prefs.getStringList('roles') ?? [];

    // Convert the List<String> roles back to List<int>
    final roles = rolesStringList.map((e) => int.tryParse(e) ?? 0).toList();

    if (userId != null && userUid != null) {
      return UserModel(
        id: userId,
        uid: userUid,
        email: userEmail ?? '',
        username: username ?? '',
        name: name ?? '',
        status: status ?? '',
        roles: roles, // Now this is List<int>
      );
    }
    return null;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userUid');
    await prefs.remove('userEmail');
    await prefs.remove('username');
    await prefs.remove('name');
    await prefs.remove('roles');
  }
}
