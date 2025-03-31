import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:otomoto/admin/pages/vehicle/vehicle_forms/add_vehicle.dart';
import 'package:otomoto/admin/pages/vehicle/vehicle_forms/delete_vehicle.dart';
import 'package:otomoto/admin/pages/vehicle/vehicle_forms/maintenance_vehicle.dart';
import 'package:otomoto/admin/pages/vehicle/vehicle_forms/update_vehicle.dart';
import 'package:otomoto/admin/pages/vehicle/vehicle_forms/view_vehicle.dart';

class VehicleManagement extends StatefulWidget {
  const VehicleManagement({super.key});

  @override
  _VehicleManagementState createState() => _VehicleManagementState();
}

class _VehicleManagementState extends State<VehicleManagement> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> vehicleList = [];
  List<Map<String, dynamic>> filteredVehicles = [];
  late VehicleDataSource _dataSource;
  static const int rowsPerPage = 10;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dataSource = VehicleDataSource(
        [], _viewVehicle, _updateVehicle, _maintenanceVehicle, _deleteVehicle);
    _fetchVehicles();
  }

  void _fetchVehicles() {
    FirebaseFirestore.instance.collection('vehicles').snapshots().listen(
      (snapshot) {
        if (!mounted) return;
        setState(() {
          vehicleList = snapshot.docs
              .map((doc) => {
                    'id': doc['vehicle_id'].toString(),
                    'brand': doc['brand'] ?? '',
                    'model': doc['model'] ?? '',
                    'plate_num': doc['plate_num'] ?? '',
                    'body_type': doc['body_type'] ?? '',
                    'color': doc['color'] ?? '',
                    'rental_rate': doc['rental_rate'] ?? '',
                    'status': doc['status'] ?? '',
                  })
              .toList();

          filteredVehicles = List.from(vehicleList);
          _dataSource = VehicleDataSource(filteredVehicles, _viewVehicle,
              _updateVehicle, _maintenanceVehicle, _deleteVehicle);
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

  void _filterVehicles(String query) {
    setState(() {
      filteredVehicles = query.isEmpty
          ? List.from(vehicleList)
          : vehicleList
              .where((vehicle) =>
                  vehicle['brand']!
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  vehicle['model']!
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  vehicle['body_type']!
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  vehicle['color']!
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  vehicle['plate_num']!
                      .toLowerCase()
                      .contains(query.toLowerCase()))
              .toList();

      _dataSource = VehicleDataSource(filteredVehicles, _viewVehicle,
          _updateVehicle, _maintenanceVehicle, _deleteVehicle);
    });
  }

  void _filterByVehicleId(String query) {
    setState(() {
      filteredVehicles = query.isEmpty
          ? List.from(vehicleList)
          : vehicleList
              .where((staff) =>
                  staff['id']!.toLowerCase().contains(query.toLowerCase()))
              .toList();

      _dataSource = VehicleDataSource(filteredVehicles, _viewVehicle,
          _updateVehicle, _maintenanceVehicle, _deleteVehicle);
    });
  }

  void _addVehicle() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 500,
          child: AddVehicleForm(),
        ),
      ),
    );
  }

  void _updateVehicle(int index) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
            width: 500,
            child: UpdateVehicleForm(
              vehicleId: filteredVehicles[index]['id']!,
              brand: filteredVehicles[index]['brand']!,
              model: filteredVehicles[index]['model']!,
              plateNumber: filteredVehicles[index]['plate_num']!,
              bodyType: filteredVehicles[index]['body_type']!,
              color: filteredVehicles[index]['color']!,
              rentalRate: filteredVehicles[index]['rental_rate']!,
              status: filteredVehicles[index]['status']!,
            )),
      ),
    );
  }

  void _viewVehicle(int index) {
    showDialog(
      context: context,
      builder: (context) => ViewVehicleForm(
        vehicleId: filteredVehicles[index]['id']!,
        brand: filteredVehicles[index]['brand']!,
        model: filteredVehicles[index]['model']!,
        plateNumber: filteredVehicles[index]['plate_num']!,
        bodyType: filteredVehicles[index]['body_type']!,
        color: filteredVehicles[index]['color']!,
        rentalRate: filteredVehicles[index]['rental_rate']!,
        status: filteredVehicles[index]['status']!,
      ),
    );
  }

  void _deleteVehicle(int index) async {
    showDialog(
      context: context,
      builder: (context) => DeleteVehicleDialog(
        vehicleId: filteredVehicles[index]['id']!,
        brand: filteredVehicles[index]['brand']!,
        model: filteredVehicles[index]['model']!,
        plateNumber: filteredVehicles[index]['plate_num']!,
      ),
    );
  }

  void _maintenanceVehicle(int index) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 500,
          child: MaintenanceVehicleForm(
            vehicleId: filteredVehicles[index]['id']!,
            brand: filteredVehicles[index]['brand']!,
            model: filteredVehicles[index]['model']!,
            plateNumber: filteredVehicles[index]['plate_num']!,
          ),
        ),
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
            onChanged: _filterVehicles,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 200, // Fixed width for ID search
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
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _addVehicle,
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
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Brand')),
                    DataColumn(label: Text('Model')),
                    DataColumn(label: Text('Plate Number')),
                    DataColumn(label: Text('Body Type')),
                    DataColumn(label: Text('Color')),
                    DataColumn(label: Text('Rental Rate')),
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

class VehicleDataSource extends DataTableSource {
  final List<Map<String, dynamic>> vehicles;
  final Function(int) onView;
  final Function(int) onUpdate;
  final Function(int) onMaintenance;
  final Function(int) onDelete;

  VehicleDataSource(this.vehicles, this.onView, this.onUpdate,
      this.onMaintenance, this.onDelete);

  @override
  DataRow? getRow(int index) {
    if (index >= vehicles.length) return null;
    final vehicle = vehicles[index];
    return DataRow(cells: [
      DataCell(Text(vehicle['id'])),
      DataCell(Text(vehicle['brand'])),
      DataCell(Text(vehicle['model'])),
      DataCell(Text(vehicle['plate_num'])),
      DataCell(Text(vehicle['body_type'])),
      DataCell(Text(vehicle['color'])),
      DataCell(Text("₱ ${vehicle['rental_rate']}")),
      DataCell(Text(
        vehicle['status'],
        style: TextStyle(
          color: vehicle['status'] == 'Available'
              ? Colors.green
              : vehicle['status'] == 'Unavailable'
                  ? Colors.red
                  : Colors.orange,
          fontWeight: FontWeight.bold,
        ),
      )),
      DataCell(Row(
        children: [
          _buildIconButton(
              Icons.visibility, Colors.orange, () => onView(index)),
          _buildIconButton(Icons.edit, Colors.blue, () => onUpdate(index)),
          _buildIconButton(Icons.car_crash_sharp, Colors.blueGrey,
              () => onMaintenance(index)),
          _buildIconButton(Icons.delete, Colors.red, () => onDelete(index)),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => vehicles.length;

  @override
  int get selectedRowCount => 0;

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onPressed,
    );
  }
}
