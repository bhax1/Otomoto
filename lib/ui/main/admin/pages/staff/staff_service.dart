import 'package:cloud_firestore/cloud_firestore.dart';

class StaffService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Map<String, String> _roleNameCache = {};

  Future<List<Map<String, dynamic>>> fetchStaff(
      String nameQuery, String staffIdQuery) async {
    List<Map<String, dynamic>> staffDataList = [];

    if (staffIdQuery.isNotEmpty) {
      final docSnapshot =
          await firestore.collection('staff').doc(staffIdQuery).get();
      if (docSnapshot.exists) {
        staffDataList.add(await _buildStaffMap(docSnapshot));
      }
    } else if (nameQuery.isNotEmpty) {
      final normalizedQuery = nameQuery.toLowerCase().trim();

      QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('staff')
          .where('search_keywords', arrayContains: normalizedQuery)
          .get();

      if (snapshot.docs.isEmpty) {
        QuerySnapshot<Map<String, dynamic>> snapshot =
            await firestore.collection('staff').get();
        staffDataList = await Future.wait(snapshot.docs.map(_buildStaffMap));

        staffDataList = staffDataList.where((staff) {
          final fullName =
              '${staff['firstname']} ${staff['lastname']}'.toLowerCase();
          final email = staff['email']?.toLowerCase() ?? '';
          final contact = staff['contact']?.toLowerCase() ?? '';

          return fullName.contains(normalizedQuery) ||
              email.contains(normalizedQuery) ||
              contact.contains(normalizedQuery);
        }).toList();
      } else {
        staffDataList = await Future.wait(snapshot.docs.map(_buildStaffMap));
      }
    } else {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await firestore.collection('staff').get();
      staffDataList = await Future.wait(snapshot.docs.map(_buildStaffMap));
    }

    return staffDataList;
  }

  Future<String> _getRoleName(String roleId) async {
    if (_roleNameCache.containsKey(roleId)) {
      return _roleNameCache[roleId]!;
    }

    final roleSnapshot = await firestore.collection('role').doc(roleId).get();
    final name = roleSnapshot.data()?['name'] ?? 'Unknown Role';
    _roleNameCache[roleId] = name;
    return name;
  }

  Future<Map<String, dynamic>> _buildStaffMap(
    DocumentSnapshot<Map<String, dynamic>> staffDoc,
  ) async {
    final staffData = staffDoc.data();
    final staffId = staffDoc.id;

    final profileSnapshot =
        await firestore.collection('staff_profiles').doc(staffId).get();
    final profileData = profileSnapshot.data();

    List<String> roleNames = [];

    final roles = staffData?['roles'];
    if (roles is List && roles.isNotEmpty) {
      final roleFutures =
          roles.map((roleId) => _getRoleName(roleId.toString()));
      roleNames = await Future.wait(roleFutures);
      roleNames = roleNames.where((name) => name.isNotEmpty).toList();
    }

    return {
      'id': staffId,
      'firstname': profileData?['first_name'] ?? '',
      'lastname': profileData?['last_name'] ?? '',
      'contact': profileData?['phone_number'] ?? '',
      'email': staffData?['email'] ?? '',
      'status': staffData?['status']?.toLowerCase() ?? '',
      'roles': roleNames.join(', '),
      'raw_roles': roles ?? [],
    };
  }
}
