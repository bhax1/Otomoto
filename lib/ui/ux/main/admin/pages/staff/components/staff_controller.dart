import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otomoto/ui/ux/main/admin/pages/staff/components/staff_models.dart';
import 'package:otomoto/ui/ux/main/admin/pages/staff/components/staff_providers.dart';

class StaffController extends StateNotifier<StaffState> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _staffUpdateListener;
  bool _isLocalChange = false;

  StaffController() : super(StaffState()) {
    setupRealtimeListener();
    fetchStaff();
  }

  @override
  void dispose() {
    _staffUpdateListener?.cancel();
    super.dispose();
  }

  Future<void> fetchStaff({int page = 0, bool resetPage = false}) async {
    final currentPage = resetPage ? 0 : page;
    state =
        state.copyWith(isLoading: true, error: null, currentPage: currentPage);

    try {
      final staffSnapshot = await firestore
          .collection('staff')
          .orderBy('staff_id')
          .startAt([page * StaffState.rowsPerPage]) // Updated here
          .limit(StaffState.rowsPerPage) // Updated here
          .get();

      List<StaffMember> staffDataList = [];
      for (var staffDoc in staffSnapshot.docs) {
        final staffData = staffDoc.data();
        final staffId = staffDoc.id;

        final profileSnapshot =
            await firestore.collection('staff_profiles').doc(staffId).get();
        final profileData = profileSnapshot.data();

        String roleName = '';
        if (staffData['roles'] != null && staffData['roles'].isNotEmpty) {
          final roleId = staffData['roles'][0];
          final roleSnapshot =
              await firestore.collection('roles').doc(roleId.toString()).get();
          if (roleSnapshot.exists) {
            final roleData = roleSnapshot.data();
            roleName = roleData?['name'] ?? '';
          }
        }

        final staffMap = {
          'id': staffData['staff_id'].toString(),
          'firstname': profileData?['first_name'] ?? '',
          'lastname': profileData?['last_name'] ?? '',
          'contact': profileData?['phone_number'] ?? '',
          'email': staffData['email'] ?? '',
          'status': staffData['status'] ?? '',
          'job_position': profileData?['job_position'] ?? roleName,
        };

        staffDataList.add(StaffMember.fromMap(staffMap));
      }

      state = state.copyWith(
        staffList: staffDataList,
        filteredStaff: staffDataList,
        isLoading: false,
        currentPage: page,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch staff data: $e',
      );
    }
  }

  void setupRealtimeListener() {
    _staffUpdateListener =
        firestore.collection('staff').snapshots().listen((_) {
      if (_isLocalChange) {
        _isLocalChange = false;
        return;
      }
      state = state.copyWith(externalUpdatesAvailable: true);
    });
  }

  Future<void> handleRefresh() async {
    state = state.copyWith(
      externalUpdatesAvailable: false,
      isLoading: true,
    );
    _isLocalChange = false;
    await fetchStaff(page: state.currentPage);
  }

  void filterStaff(String query) {
    _filter(query, 'name');
  }

  void filterByStaffId(String query) {
    _filter(query, 'id');
  }

  void _filter(String query, String type) {
    final filtered = query.isEmpty
        ? state.staffList
        : state.staffList.where((staff) {
            if (type == 'name') {
              String fullName =
                  "${staff.firstname} ${staff.lastname}".toLowerCase();
              return fullName.contains(query.toLowerCase()) ||
                  staff.firstname.toLowerCase().contains(query.toLowerCase()) ||
                  staff.lastname.toLowerCase().contains(query.toLowerCase()) ||
                  staff.jobPosition
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  staff.contact.toLowerCase().contains(query.toLowerCase()) ||
                  staff.email.toLowerCase().contains(query.toLowerCase());
            } else {
              return staff.id.toLowerCase().contains(query.toLowerCase());
            }
          }).toList();

    state = state.copyWith(filteredStaff: filtered);
  }

  void markLocalChange() {
    _isLocalChange = true;
  }
}
