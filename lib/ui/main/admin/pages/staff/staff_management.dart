import 'package:flutter/material.dart';
import 'package:otomoto/ui/main/admin/pages/staff/staff_forms/add_staff.dart';
import 'package:otomoto/ui/main/admin/pages/staff/staff_forms/delete_staff.dart';
import 'package:otomoto/ui/main/admin/pages/staff/staff_forms/update_staff.dart';
import 'package:otomoto/ui/main/admin/pages/staff/staff_forms/view_staff.dart';
import 'package:otomoto/ui/main/admin/pages/staff/staff_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:otomoto/ui/main/admin/pages/staff/staff_data_source.dart';

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
  bool _isLoading = true;
  String _nameQuery = '';
  String _staffIdQuery = '';
  final StaffService _staffService = StaffService();

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  Future<void> _fetchStaff() async {
    setState(() => _isLoading = true);
    try {
      final staffDataList =
          await _staffService.fetchStaff(_nameQuery, _staffIdQuery);
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
                _fetchStaff();
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
      _fetchStaff();
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
      _fetchStaff();
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
      _fetchStaff();
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
                    // Optionally store it in a separate controller
                    // or use a separate TextEditingController if needed.
                    _staffIdQuery = value;
                  },
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _nameQuery = _searchController.text.trim();
                  });
                  _fetchStaff();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child:
                    const Text('Search', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  _nameQuery = '';
                  _staffIdQuery = '';
                  _fetchStaff();
                },
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

  Widget _buildDataTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: constraints.maxWidth,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: PaginatedDataTable(
                columns: const [
                  DataColumn(label: Text('Staff ID')),
                  DataColumn(label: Text('First Name')),
                  DataColumn(label: Text('Last Name')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Contact Number')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                source: _dataSource,
                rowsPerPage: 10,
                onPageChanged: (int pageIndex) {},
                showFirstLastButtons: true,
              ),
            ),
          ),
        );
      },
    );
  }
}
