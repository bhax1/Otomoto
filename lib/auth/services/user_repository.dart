import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otomoto/core/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore firestore;

  UserRepository(this.firestore);

  Future<UserModel?> getUserByEmail(String? email) async {
    if (email == null) return null;

    final userQuery = await firestore
        .collection('staff')
        .where('email', isEqualTo: email)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (userQuery.docs.isEmpty) return null;
    final staffDoc = userQuery.docs.first;
    final data = staffDoc.data();
    final staffId = staffDoc.id;

    // Get name from staff_profiles
    final profileDoc =
        await firestore.collection('staff_profiles').doc(staffId).get();
    final profileData = profileDoc.data();
    final firstName = profileData?['first_name'] ?? '';
    final lastName = profileData?['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim();

    return UserModel(
      id: staffId,
      uid: data['auth_id'] ?? '',
      email: data['email'],
      username: data['username'],
      roles: List<int>.from(data['roles'] ?? []),
      status: data['status'],
      name: fullName,
    );
  }

  Future<void> updateLastLogin(String userId) async {
    await firestore.collection('staff').doc(userId).update({
      'last_login': FieldValue.serverTimestamp(),
    });
  }
}
