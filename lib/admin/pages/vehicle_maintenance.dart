import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VehicleMaintenance extends StatefulWidget {
  const VehicleMaintenance({super.key});

  @override
  _VehicleMaintenanceState createState() => _VehicleMaintenanceState();
}

class _VehicleMaintenanceState extends State<VehicleMaintenance> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> maintenanceList = [];
  List<Map<String, dynamic>> filteredMaintenance = [];
  late MaintenanceDataSource _dataSource;
  static const int rowsPerPage = 10;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dataSource = MaintenanceDataSource([]);
    _fetchMaintenanceRecords();
  }

  void _fetchMaintenanceRecords() {
    FirebaseFirestore.instance.collection('maintenance').snapshots().listen(
      (snapshot) {
        if (!mounted) return;
        setState(() {
          maintenanceList = snapshot.docs
              .map((doc) => {
                    'id': doc['maintenance_id'],
                    'vehicle_id': doc['vehicle_id'],
                    'maintenance_type': doc['maintenance_type'].join(", "),
                    'start_date': doc['start_date'],
                    'end_date': doc['end_date'],
                    'status': doc['status'],
                  })
              .toList();

          filteredMaintenance = List.from(maintenanceList);
          _dataSource = MaintenanceDataSource(filteredMaintenance);
          _isLoading = false;
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching maintenance records: $error')),
        );
      },
    );
  }

  void _filterMaintenance(String query) {
    setState(() {
      filteredMaintenance = query.isEmpty
          ? List.from(maintenanceList)
          : maintenanceList
              .where((record) =>
                  record['vehicle_id'].contains(query) ||
                  record['maintenance_type']
                      .toLowerCase()
                      .contains(query.toLowerCase()))
              .toList();

      _dataSource = MaintenanceDataSource(filteredMaintenance);
    });
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
            onChanged: _filterMaintenance,
          ),
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
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Vehicle ID')),
                    DataColumn(label: Text('Maintenance Type')),
                    DataColumn(label: Text('Start Date')),
                    DataColumn(label: Text('End Date')),
                    DataColumn(label: Text('Status')),
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

class MaintenanceDataSource extends DataTableSource {
  final List<Map<String, dynamic>> maintenanceRecords;
  final DateFormat dateFormat = DateFormat('MMMM d, y');

  MaintenanceDataSource(this.maintenanceRecords);

  @override
  DataRow? getRow(int index) {
    if (index >= maintenanceRecords.length) return null;
    final record = maintenanceRecords[index];

    String formatDate(String dateString) {
      DateTime dateTime = DateTime.parse(dateString);
      return dateFormat.format(dateTime);
    }

    return DataRow(cells: [
      DataCell(Text(record['id'].toString())),
      DataCell(Text(record['vehicle_id'].toString())),
      DataCell(Text(record['maintenance_type'].toString())),
      DataCell(Text(formatDate(record['start_date']))),
      DataCell(Text(formatDate(record['end_date']))),
      DataCell(Text(record['status'].toString())),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => maintenanceRecords.length;

  @override
  int get selectedRowCount => 0;
}
