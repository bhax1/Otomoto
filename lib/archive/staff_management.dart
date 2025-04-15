import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:otomoto/ui/main/admin/pages/staff/staff_forms/add_staff.dart';
import 'package:otomoto/ui/main/admin/pages/staff/staff_forms/delete_staff.dart';
import 'package:otomoto/ui/main/admin/pages/staff/staff_forms/update_staff.dart';
import 'package:otomoto/ui/main/admin/pages/staff/staff_forms/view_staff.dart';

class StaffManagement extends StatefulWidget {
  const StaffManagement({super.key});

  @override
  _StaffManagementState createState() => _StaffManagementState();
}

class _StaffManagementState extends State<StaffManagement> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> staffList = [];
  List<Map<String, dynamic>> filteredStaff = [];
  late StaffDataSource _dataSource;
  static const int rowsPerPage = 10;
  bool _isLoading = true;
  int currentPage = 0;
  final firestore = FirebaseFirestore.instance;
  bool _isLocalChange = false;
  StreamSubscription<QuerySnapshot>? _staffUpdateListener;
  String _nameQuery = '';
  String _staffIdQuery = '';

  @override
  void initState() {
    super.initState();
    _setupRealtimeListener();
    _fetchStaff();
  }

  @override
  void dispose() {
    _staffUpdateListener?.cancel();
    super.dispose();
  }

  void _setupRealtimeListener() {
    _staffUpdateListener =
        firestore.collection('staff').snapshots().listen((_) {
      if (_isLocalChange) {
        _isLocalChange = false;
        return;
      }
      _fetchStaff(page: currentPage);
    });
  }

  Future<void> _fetchStaff({int page = 0}) async {
    setState(() => _isLoading = true);
    try {
      final staffSnapshot = await firestore
          .collection('staff')
          .orderBy('staff_id')
          .startAt([page * rowsPerPage])
          .limit(rowsPerPage)
          .get();

      List<Map<String, dynamic>> staffDataList = [];
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

        staffDataList.add(staffMap);
      }

      setState(() {
        staffList = staffDataList;
        filteredStaff = List.from(staffList);
        _dataSource = StaffDataSource(
            filteredStaff, _viewStaff, _updateStaff, _deleteStaff);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text("Failed to fetch staff data: $errorMessage"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _fetchStaff(page: currentPage);
              },
              child: const Text("Try Again"),
            ),
          ],
        );
      },
    );
  }

  void _addStaff() async {
    final result = await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const SizedBox(width: 500, child: AddStaffForm()),
      ),
    );
    if (result == true) {
      _isLocalChange = true;
      _fetchStaff(page: currentPage);
    }
  }

  void _viewStaff(int index) {
    showDialog(
      context: context,
      builder: (context) => ViewStaffForm(
        staffId: filteredStaff[index]['id']!,
      ),
    );
  }

  void _updateStaff(int index) async {
    final result = await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 500,
          child: UpdateStaffForm(
            staffId: filteredStaff[index]['id']!,
          ),
        ),
      ),
    );

    if (result == true) {
      _isLocalChange = true;
      _fetchStaff(page: currentPage);
    }
  }

  void _deleteStaff(int index) async {
    final result = await showDialog(
      context: context,
      builder: (context) => DeleteStaffDialog(
        staffId: filteredStaff[index]['id']!,
        staffName:
            "${filteredStaff[index]['firstname']} ${filteredStaff[index]['lastname']}",
      ),
    );
    if (result == true) {
      _isLocalChange = true;
      _fetchStaff(page: currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: SpinKitThreeBounce(
                        color: Colors.blueGrey,
                        size: 30.0,
                      ),
                    )
                  : _buildDataTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by name, contact, email...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (value) {
                    _nameQuery = value;
                  },
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 200,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Staff ID',
                    prefixIcon: const Icon(Icons.confirmation_number_sharp),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (value) {
                    _staffIdQuery = value;
                  },
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child:
                    const Text('Search', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _resetSearch,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child:
                    const Text('Clear', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: _addStaff,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('+ Add', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);
    try {
      List<Map<String, dynamic>> staffDataList = [];

      if (_staffIdQuery.isNotEmpty) {
        final docSnapshot =
            await firestore.collection('staff').doc(_staffIdQuery).get();

        if (docSnapshot.exists) {
          staffDataList.add(await _buildStaffMap(docSnapshot));
        }
      } else {
        QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
            .collection('staff')
            .where('search_keywords', arrayContains: _nameQuery.toLowerCase())
            .get();

        staffDataList = await Future.wait(snapshot.docs.map(_buildStaffMap));
      }

      setState(() {
        staffList = staffDataList;
        filteredStaff = List.from(staffDataList);
        _dataSource = StaffDataSource(
            filteredStaff, _viewStaff, _updateStaff, _deleteStaff);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(
          'Something went wrong while searching. Please try again.');
      debugPrint('Search error: $e');
    }
  }

  Future<Map<String, dynamic>> _buildStaffMap(
      DocumentSnapshot<Map<String, dynamic>> staffDoc) async {
    final staffData = staffDoc.data();
    final staffId = staffDoc.id;

    final profileSnapshot =
        await firestore.collection('staff_profiles').doc(staffId).get();
    final profileData = profileSnapshot.data();

    String roleName = '';
    final roles = staffData?['roles'];
    if (roles is List && roles.isNotEmpty) {
      final roleId = roles[0].toString();
      final roleSnapshot =
          await firestore.collection('roles').doc(roleId).get();
      if (roleSnapshot.exists) {
        final roleData = roleSnapshot.data();
        roleName = roleData?['name'] ?? '';
      }
    }

    return {
      'id': staffId,
      'firstname': profileData?['first_name'] ?? '',
      'lastname': profileData?['last_name'] ?? '',
      'contact': profileData?['phone_number'] ?? '',
      'email': staffData?['email'] ?? '',
      'status': staffData?['status'] ?? '',
      'job_position': profileData?['job_position'] ?? roleName,
    };
  }

  void _resetSearch() {
    _searchController.clear();
    _nameQuery = '';
    _staffIdQuery = '';
    _fetchStaff(page: currentPage);
  }

  Widget _buildDataTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: constraints.maxWidth,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTableTheme(
                data: DataTableThemeData(
                  headingRowColor: WidgetStateProperty.all(Colors.amber),
                  headingTextStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  dataRowColor:
                      WidgetStateProperty.resolveWith<Color?>((states) {
                    return states.contains(WidgetState.selected)
                        ? Colors.grey[300]
                        : null;
                  }),
                  dataTextStyle: const TextStyle(color: Colors.black87),
                  dividerThickness: 1.5,
                ),
                child: PaginatedDataTable(
                  columns: const [
                    DataColumn(label: Text('Staff ID')),
                    DataColumn(label: Text('First Name')),
                    DataColumn(label: Text('Last Name')),
                    DataColumn(label: Text('Job Position')),
                    DataColumn(label: Text('Contact Number')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  source: _dataSource,
                  rowsPerPage: rowsPerPage,
                  onPageChanged: (int pageIndex) {
                    setState(() {
                      currentPage = pageIndex;
                    });
                    _fetchStaff(page: currentPage);
                  },
                  showFirstLastButtons: true,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class StaffDataSource extends DataTableSource {
  final List<Map<String, dynamic>> staff;
  final Function(int) onView;
  final Function(int) onUpdate;
  final Function(int) onDelete;

  StaffDataSource(this.staff, this.onView, this.onUpdate, this.onDelete);

  @override
  DataRow? getRow(int index) {
    if (index >= staff.length) return null;
    final staffMember = staff[index];

    String status = staffMember['status'];
    status = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1).toLowerCase()
        : '';

    return DataRow(cells: [
      DataCell(Text(staffMember['id'])),
      DataCell(Text(staffMember['firstname'])),
      DataCell(Text(staffMember['lastname'])),
      DataCell(Text(staffMember['job_position'])),
      DataCell(Text(staffMember['contact'])),
      DataCell(Text(staffMember['email'])),
      DataCell(
        Text(
          status,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: staffMember['status'] == 'active'
                ? Colors.green
                : staffMember['status'] == 'inactive'
                    ? Colors.red
                    : Colors.blueGrey,
          ),
        ),
      ),
      DataCell(
        Row(
          children: [
            _buildIconButton(
                Icons.visibility, Colors.orange, () => onView(index)),
            if (staffMember['status'] != "Removed") ...[
              _buildIconButton(Icons.edit, Colors.blue, () => onUpdate(index)),
              _buildIconButton(Icons.delete, Colors.red, () => onDelete(index)),
            ]
          ],
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => staff.length;

  @override
  int get selectedRowCount => 0;

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onPressed,
    );
  }
}
