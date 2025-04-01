import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:otomoto/admin/pages/maintenance/maintenance_forms/cancel_maintenance.dart';
import 'package:otomoto/admin/pages/maintenance/maintenance_forms/view_maintenance.dart';
import 'package:otomoto/logic/fetch_service.dart';

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

  final FetchService _fetchService = FetchService();

  @override
  void initState() {
    super.initState();
    _updateOverdueMaintenanceStatus();
    _dataSource = MaintenanceDataSource([], _viewMaintenance,
        _updateMaintenance, _cancelMaintenance, _doneMaintenance);
    _fetchMaintenanceRecords();
  }

  Future<void> _updateOverdueMaintenanceStatus() async {
    try {
      final maintenanceCollection =
          FirebaseFirestore.instance.collection('maintenance');
      final currentDate = DateTime.now();

      final overdueSnapshot = await maintenanceCollection
          .where('end_date', isLessThan: currentDate.toIso8601String())
          .where('status', isNotEqualTo: 'Overdue')
          .get();

      for (var doc in overdueSnapshot.docs) {
        await maintenanceCollection.doc(doc.id).update({
          'status': 'Overdue',
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Error updating overdue maintenance: $e");
    }
  }

  void _fetchMaintenanceRecords() {
    _fetchService.fetchMaintenance().listen(
      (maintenanceData) {
        if (!mounted) return;
        setState(() {
          maintenanceList = maintenanceData;
          filteredMaintenance = List.from(maintenanceList);
          _dataSource = MaintenanceDataSource(
              filteredMaintenance,
              _viewMaintenance,
              _updateMaintenance,
              _cancelMaintenance,
              _doneMaintenance);
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
    String formatDate(String dateString) {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat("MMMM d, yyyy").format(dateTime);
    }

    setState(() {
      filteredMaintenance = query.isEmpty
          ? List.from(maintenanceList)
          : maintenanceList.where((record) {
              bool matchesType = record['maintenance_type']
                  .toLowerCase()
                  .contains(query.toLowerCase());

              bool matchesStartDate = record['start_date'] != null &&
                  formatDate(record['start_date']!)
                      .toLowerCase()
                      .contains(query.toLowerCase());

              bool matchesEndDate = record['end_date'] != null &&
                  formatDate(record['end_date']!)
                      .toLowerCase()
                      .contains(query.toLowerCase());

              bool matchesStatus =
                  record['status'].toLowerCase().contains(query.toLowerCase());

              return matchesType ||
                  matchesStartDate ||
                  matchesEndDate ||
                  matchesStatus;
            }).toList();

      _dataSource = MaintenanceDataSource(filteredMaintenance, _viewMaintenance,
          _updateMaintenance, _cancelMaintenance, _doneMaintenance);
    });
  }

  void _filterByMaintenanceId(String query) {
    setState(() {
      filteredMaintenance = query.isEmpty
          ? List.from(maintenanceList)
          : maintenanceList
              .where((staff) => staff['id']!
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
              .toList();

      _dataSource = MaintenanceDataSource(filteredMaintenance, _viewMaintenance,
          _updateMaintenance, _cancelMaintenance, _doneMaintenance);
    });
  }

  void _filterByVehicleId(String query) {
    setState(() {
      filteredMaintenance = query.isEmpty
          ? List.from(maintenanceList)
          : maintenanceList
              .where((staff) => staff['vehicle_id']!
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
              .toList();
      _dataSource = MaintenanceDataSource(filteredMaintenance, _viewMaintenance,
          _updateMaintenance, _cancelMaintenance, _doneMaintenance);
    });
  }

  void _viewMaintenance(int index) {
    showDialog(
      context: context,
      builder: (context) => ViewMaintenanceForm(
        maintenanceId: filteredMaintenance[index]['id']!,
        vehicleId: filteredMaintenance[index]['vehicle_id']!,
      ),
    );
  }

  void _updateMaintenance(int index) {}

  void _cancelMaintenance(int index) {
    showDialog(
      context: context,
      builder: (context) => CancelMaintenanceForm(
        maintenanceId: filteredMaintenance[index]['id']!,
        vehicleId: filteredMaintenance[index]['vehicle_id']!,
      ),
    );
  }

  void _doneMaintenance(int index) {}

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
        const SizedBox(width: 10),
        SizedBox(
          width: 200, // Fixed width for ID search
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Maintenance ID',
              prefixIcon: const Icon(Icons.confirmation_number_sharp),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: _filterByMaintenanceId,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 150, // Fixed width for ID search
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Vehicle ID',
              prefixIcon: const Icon(Icons.confirmation_number_sharp),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: _filterByVehicleId,
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

class MaintenanceDataSource extends DataTableSource {
  final List<Map<String, dynamic>> maintenanceRecords;
  final DateFormat dateFormat = DateFormat('MMMM d, y');
  final Function(int) onView;
  final Function(int) onUpdate;
  final Function(int) onCancel;
  final Function(int) onDone;

  MaintenanceDataSource(this.maintenanceRecords, this.onView, this.onUpdate,
      this.onCancel, this.onDone);

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
      DataCell(Text(
        record['status'].toString(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _getStatusColor(record['status'].toString()),
        ),
      )),
      DataCell(Row(
        children: [
          _buildIconButton(
              Icons.visibility, Colors.orange, () => onView(index)),
          if (record['status'] != "Cancelled" &&
              record['status'] != "Done" &&
              record['status'] != "Overdue") ...[
            _buildIconButton(Icons.update, Colors.blue, () => onUpdate(index)),
            _buildIconButton(
                Icons.cancel_outlined, Colors.red, () => onCancel(index)),
            _buildIconButton(Icons.done, Colors.green, () => onDone(index)),
          ]
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => maintenanceRecords.length;

  @override
  int get selectedRowCount => 0;

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onPressed,
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Done":
        return Colors.green;
      case "Active":
        return Colors.blue;
      case "Cancelled":
        return Colors.redAccent;
      case "Overdue":
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
