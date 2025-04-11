import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:otomoto/ui/ux/main/admin/pages/staff/staff_forms/add_staff.dart';
import 'package:otomoto/ui/ux/main/admin/pages/staff/staff_forms/delete_staff.dart';
import 'package:otomoto/ui/ux/main/admin/pages/staff/staff_forms/update_staff.dart';
import 'package:otomoto/ui/ux/main/admin/pages/staff/staff_forms/view_staff.dart';

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
  bool _externalUpdatesAvailable = false;
  bool _isLocalChange = false;
  StreamSubscription<QuerySnapshot>? _staffUpdateListener;

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
      if (mounted) setState(() => _externalUpdatesAvailable = true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchStaff();
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

        // Fetch profile document
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

  void _handleRefresh() {
    setState(() => _externalUpdatesAvailable = false);
    _fetchStaff(page: currentPage);
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
              onPressed: () {
                Navigator.of(context).pop();
              },
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

  void _filterStaff(String query) {
    _filter(query, 'name');
  }

  void _filterByStaffId(String query) {
    _filter(query, 'id');
  }

  void _filter(String query, String type) {
    setState(() {
      filteredStaff = query.isEmpty
          ? List.from(staffList)
          : staffList.where((staff) {
              if (type == 'name') {
                String fullName =
                    "${staff['firstname']} ${staff['lastname']}".toLowerCase();
                return fullName.contains(query.toLowerCase()) ||
                    staff['firstname']!
                        .toLowerCase()
                        .contains(query.toLowerCase()) ||
                    staff['lastname']!
                        .toLowerCase()
                        .contains(query.toLowerCase()) ||
                    staff['job_position']!
                        .toLowerCase()
                        .contains(query.toLowerCase()) ||
                    staff['contact']!
                        .toLowerCase()
                        .contains(query.toLowerCase()) ||
                    staff['email']!.toLowerCase().contains(query.toLowerCase());
              } else {
                return staff['id']!.toLowerCase().contains(query.toLowerCase());
              }
            }).toList();
      _dataSource = StaffDataSource(
          filteredStaff, _viewStaff, _updateStaff, _deleteStaff);
    });
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
      _fetchStaff(page: currentPage); // Immediate refresh for current admin
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
                  ? const Center(child: CircularProgressIndicator())
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
        SizedBox(
          width: 300,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search...',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: _filterStaff,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 200,
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Staff ID',
              prefixIcon: const Icon(Icons.confirmation_number_sharp),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: _filterByStaffId,
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _addStaff,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('+ Add', style: TextStyle(color: Colors.white)),
        ),
        const Spacer(),
        if (_externalUpdatesAvailable)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Badge(
              smallSize: 8,
              backgroundColor: Colors.red,
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _handleRefresh,
              ),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
          ),
      ],
    );
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
