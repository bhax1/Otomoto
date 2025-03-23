import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:otomoto/admin/pages/staff_forms/add_staff.dart';
import 'package:otomoto/admin/pages/staff_forms/delete_staff.dart';
import 'package:otomoto/admin/pages/staff_forms/update_staff.dart';
import 'package:otomoto/admin/pages/staff_forms/view_staff.dart';

class StaffManagement extends StatefulWidget {
  const StaffManagement({super.key});

  @override
  _StaffManagementState createState() => _StaffManagementState();
}

class _StaffManagementState extends State<StaffManagement> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> staffList = [];
  List<Map<String, String>> filteredStaff = [];
  late StaffDataSource _dataSource;
  static const int rowsPerPage = 10;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dataSource = StaffDataSource([], _viewStaff, _updateStaff, _deleteStaff);
    _fetchStaff();
  }

  void _fetchStaff() {
    setState(() => _isLoading = true);

    FirebaseFirestore.instance
        .collection('staffs')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        staffList = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'name': "${doc['firstname'] ?? ''} ${doc['lastname'] ?? ''}",
                  'address': doc['address']?.toString() ?? '',
                  'contact': doc['contact_num']?.toString() ?? '',
                  'email': doc['email']?.toString() ?? '',
                })
            .toList();

        filteredStaff = List.from(staffList);
        _dataSource = StaffDataSource(
            filteredStaff, _viewStaff, _updateStaff, _deleteStaff);
        _isLoading = false;
      });
    });
  }

  void _filterStaff(String query) {
    setState(() {
      filteredStaff = query.isEmpty
          ? List.from(staffList)
          : staffList
              .where((staff) =>
                  staff['name']!.toLowerCase().contains(query.toLowerCase()))
              .toList();

      _dataSource = StaffDataSource(
          filteredStaff, _viewStaff, _updateStaff, _deleteStaff);
    });
  }

  void _addStaff() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 400,
          child: AddStaffForm(),
        ),
      ),
    );
  }

  void _viewStaff(int index) {
    String staffId = filteredStaff[index]['id']!;
    String fullName = filteredStaff[index]['name']!;
    String address = filteredStaff[index]['address']!;
    String contact = filteredStaff[index]['contact']!;
    String email = filteredStaff[index]['email']!;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 400, // Ensure consistent width
          height: 500, // Set a fixed height similar to AddStaffForm
          child: ViewStaffForm(
            staffId: staffId,
            name: fullName,
            address: address,
            contact: contact,
            email: email,
          ),
        ),
      ),
    );
  }

  void _updateStaff(int index) async {
    String staffId = filteredStaff[index]['id']!;
    String fullName = filteredStaff[index]['name']!;
    List<String> nameParts = fullName.split(" ");
    String firstName = nameParts.isNotEmpty ? nameParts[0] : "";
    String lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";
    String address = filteredStaff[index]['address']!;
    String contact = filteredStaff[index]['contact']!;

    DocumentSnapshot staffSnapshot = await FirebaseFirestore.instance
        .collection('staffs')
        .doc(staffId)
        .get();
    String email = staffSnapshot['email'] ?? '';

    bool? updated = await showDialog(
      context: context,
      builder: (context) => UpdateStaffForm(
        staffId: staffId,
        firstName: firstName,
        lastName: lastName,
        address: address,
        contact: contact,
        email: email,
      ),
    );

    if (updated == true) {
      _fetchStaff(); // Refresh staff list after update
    }
  }

  void _deleteStaff(int index) async {
    String staffId = filteredStaff[index]['id']!;
    String staffName = filteredStaff[index]['name']!;

    showDialog(
      context: context,
      builder: (context) => DeleteStaffDialog(
        staffId: staffId,
        staffName: staffName,
      ),
    );
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
        Expanded(
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
              child: DataTableTheme(
                data: DataTableThemeData(
                  headingRowColor: MaterialStateProperty.all(Colors.amber),
                  headingTextStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  dataRowColor:
                      MaterialStateProperty.resolveWith<Color?>((states) {
                    return states.contains(MaterialState.selected)
                        ? Colors.grey[300]
                        : null;
                  }),
                  dataTextStyle: const TextStyle(color: Colors.black87),
                  dividerThickness: 1.5,
                ),
                child: PaginatedDataTable(
                  columns: const [
                    DataColumn(label: Text('Staff ID')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Address')),
                    DataColumn(label: Text('Contact Number')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Actions')),
                  ],
                  source: _dataSource,
                  rowsPerPage: rowsPerPage,
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
  final List<Map<String, String>> staff;
  final Function(int) onView;
  final Function(int) onUpdate;
  final Function(int) onDelete;

  StaffDataSource(this.staff, this.onView, this.onUpdate, this.onDelete);

  @override
  DataRow? getRow(int index) {
    if (index >= staff.length) return null;
    final staffMember = staff[index];
    return DataRow(cells: [
      DataCell(Text(staffMember['id']!)),
      DataCell(Text(staffMember['name']!)),
      DataCell(Text(staffMember['address']!)),
      DataCell(Text(staffMember['contact']!)),
      DataCell(Text(staffMember['email']!)),
      DataCell(
        Row(
          children: [
            _buildActionButton('View', Colors.orange, () => onView(index)),
            _buildActionButton('Update', Colors.blue, () => onUpdate(index)),
            _buildActionButton('Delete', Colors.red, () => onDelete(index)),
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

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(foregroundColor: color),
      child: Text(text),
    );
  }
}
