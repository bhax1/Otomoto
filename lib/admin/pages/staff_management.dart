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
  List<Map<String, dynamic>> staffList = [];
  List<Map<String, dynamic>> filteredStaff = [];
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
    FirebaseFirestore.instance.collection('staffs').snapshots().listen(
      (snapshot) {
        if (!mounted) return;
        setState(() {
          staffList = snapshot.docs
              .map((doc) => {
                    'id': doc['staff_id'].toString(),
                    'firstname': doc['firstname'] ?? '',
                    'lastname': doc['lastname'] ?? '',
                    'job_position': doc['job_position'] ?? '',
                    'contact': doc['contact_num'] ?? '',
                    'email': doc['email'] ?? '',
                    'status': doc['status'] == true ? 'Active' : 'Inactive',
                  })
              .toList();

          filteredStaff = List.from(staffList);
          _dataSource = StaffDataSource(
              filteredStaff, _viewStaff, _updateStaff, _deleteStaff);
          _isLoading = false;
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching staff: $error')),
        );
      },
    );
  }

  void _filterStaff(String query) {
    setState(() {
      filteredStaff = query.isEmpty
          ? List.from(staffList)
          : staffList.where((staff) {
              String fullName =
                  "${staff['firstname']!} ${staff['lastname']!}".toLowerCase();
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
            }).toList();

      _dataSource = StaffDataSource(
          filteredStaff, _viewStaff, _updateStaff, _deleteStaff);
    });
  }

  void _filterByStaffId(String query) {
    setState(() {
      filteredStaff = query.isEmpty
          ? List.from(staffList)
          : staffList
              .where((staff) =>
                  staff['id']!.toLowerCase().contains(query.toLowerCase()))
              .toList();

      _dataSource = StaffDataSource(
          filteredStaff, _viewStaff, _updateStaff, _deleteStaff);
    });
  }

  void _addStaff() async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(width: 500, child: AddStaffForm()),
      ),
    );
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
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
            width: 500,
            child: UpdateStaffForm(
              staffId: filteredStaff[index]['id']!,
            )),
      ),
    );
  }

  void _deleteStaff(int index) async {
    showDialog(
      context: context,
      builder: (context) => DeleteStaffDialog(
        staffId: filteredStaff[index]['id']!,
        staffName:
            "${filteredStaff[index]['firstname']} ${filteredStaff[index]['lastname']}",
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
        SizedBox(
          width: 300, // Fixed width for general search
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
          width: 200, // Fixed width for ID search
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
  final List<Map<String, dynamic>> staff; // Changed to dynamic
  final Function(int) onView;
  final Function(int) onUpdate;
  final Function(int) onDelete;

  StaffDataSource(this.staff, this.onView, this.onUpdate, this.onDelete);

  @override
  DataRow? getRow(int index) {
    if (index >= staff.length) return null;
    final staffMember = staff[index];
    bool isActive = staffMember['status'] == 'Active';

    return DataRow(cells: [
      DataCell(Text(staffMember['id'])),
      DataCell(Text(staffMember['firstname'])),
      DataCell(Text(staffMember['lastname'])),
      DataCell(Text(staffMember['job_position'])),
      DataCell(Text(staffMember['contact'])),
      DataCell(Text(staffMember['email'])),
      DataCell(
        Text(
          staffMember['status']!,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.green : Colors.red,
          ),
        ),
      ),
      DataCell(
        Row(
          children: [
            _buildIconButton(
                Icons.visibility, Colors.orange, () => onView(index)),
            _buildIconButton(Icons.edit, Colors.blue, () => onUpdate(index)),
            _buildIconButton(Icons.delete, Colors.red, () => onDelete(index)),
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
