import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:otomoto/admin/pages/vehicle_forms/add_vehicle.dart';
import 'package:otomoto/admin/pages/vehicle_forms/delete_vehicle.dart';
import 'package:otomoto/admin/pages/vehicle_forms/update_vehicle.dart';
import 'package:otomoto/admin/pages/vehicle_forms/view_vehicle.dart';

class VehicleManagement extends StatefulWidget {
  const VehicleManagement({super.key});

  @override
  _VehicleManagementState createState() => _VehicleManagementState();
}

class _VehicleManagementState extends State<VehicleManagement> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> vehicleList = [];
  List<Map<String, String>> filteredVehicles = [];
  late VehicleDataSource _dataSource;
  static const int rowsPerPage = 10;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dataSource =
        VehicleDataSource([], _viewVehicle, _updateVehicle, _deleteVehicle);
    _fetchVehicles();
  }

  void _fetchVehicles() {
    setState(() => _isLoading = true);

    FirebaseFirestore.instance
        .collection('vehicles')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        vehicleList = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'brand': doc['brand']?.toString() ?? '',
                  'model': doc['model']?.toString() ?? '',
                  'plate_num': doc['plate_num']?.toString() ?? '',
                  'body_type': doc['body_type']?.toString() ?? '',
                  'color': doc['color']?.toString() ?? '',
                  'rental_rate': doc['rental_rate']?.toString() ?? '',
                  'status': doc['status']?.toString() ?? '',
                })
            .toList();

        filteredVehicles = List.from(vehicleList);
        _dataSource = VehicleDataSource(
            filteredVehicles, _viewVehicle, _updateVehicle, _deleteVehicle);
        _isLoading = false;
      });
    });
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
                  vehicle['plate_num']!
                      .toLowerCase()
                      .contains(query.toLowerCase()))
              .toList();

      _dataSource = VehicleDataSource(
          filteredVehicles, _viewVehicle, _updateVehicle, _deleteVehicle);
    });
  }

  void _addVehicle() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 400,
          child: AddVehicleForm(),
        ),
      ),
    );
  }

  void _viewVehicle(int index) {
    String vehicleId = filteredVehicles[index]['id']!;
    String brand = filteredVehicles[index]['brand']!;
    String model = filteredVehicles[index]['model']!;
    String plateNum = filteredVehicles[index]['plate_num']!;
    String bodyType = filteredVehicles[index]['body_type']!;
    String color = filteredVehicles[index]['color']!;
    String rentalRate = filteredVehicles[index]['rental_rate']!;
    String status = filteredVehicles[index]['status']!;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 400, // Ensure consistent width
          height: 500, // Set a fixed height similar to AddStaffForm
          child: ViewVehicleForm(
            vehicleId: vehicleId,
            brand: brand,
            model: model,
            plateNumber: plateNum,
            bodyType: bodyType,
            color: color,
            rentalRate: rentalRate,
            status: status,
          ),
        ),
      ),
    );
  }

  void _updateVehicle(int index) async {
    String vehicleId = filteredVehicles[index]['id']!;
    String brand = filteredVehicles[index]['brand']!;
    String model = filteredVehicles[index]['model']!;
    String plateNum = filteredVehicles[index]['plate_num']!;
    String bodyType = filteredVehicles[index]['body_type']!;
    String color = filteredVehicles[index]['color']!;
    String rentalRate = filteredVehicles[index]['rental_rate']!;
    String status = filteredVehicles[index]['status']!;

    bool? updated = await showDialog(
      context: context,
      builder: (context) => UpdateVehicleForm(
        vehicleId: vehicleId,
        brand: brand,
        model: model,
        plateNumber: plateNum,
        bodyType: bodyType,
        color: color,
        rentalRate: rentalRate,
        status: status,
      ),
    );

    if (updated == true) {
      _fetchVehicles(); // Refresh staff list after update
    }
  }

  void _deleteVehicle(int index) async {
    String vehicleId = filteredVehicles[index]['id']!;
    String model = filteredVehicles[index]['model']!;

    showDialog(
      context: context,
      builder: (context) => DeleteVehicleDialog(
        vehicleId: vehicleId,
        vehicleModel: model,
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
            onChanged: _filterVehicles,
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
  final List<Map<String, String>> vehicles;
  final Function(int) onView;
  final Function(int) onUpdate;
  final Function(int) onDelete;

  VehicleDataSource(this.vehicles, this.onView, this.onUpdate, this.onDelete);

  @override
  DataRow? getRow(int index) {
    if (index >= vehicles.length) return null;
    final vehicle = vehicles[index];
    return DataRow(cells: [
      DataCell(Text(vehicle['id']!)),
      DataCell(Text(vehicle['brand']!)),
      DataCell(Text(vehicle['model']!)),
      DataCell(Text(vehicle['plate_num']!)),
      DataCell(Text(vehicle['body_type']!)),
      DataCell(Text(vehicle['color']!)),
      DataCell(Text(vehicle['rental_rate']!)),
      DataCell(Text(vehicle['status']!)),
      DataCell(Row(
        children: [
          TextButton(onPressed: () => onView(index), child: const Text('View')),
          TextButton(
              onPressed: () => onUpdate(index), child: const Text('Update')),
          TextButton(
              onPressed: () => onDelete(index), child: const Text('Delete')),
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
}
