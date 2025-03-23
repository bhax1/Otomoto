import 'package:flutter/material.dart';

class ViewVehicleForm extends StatefulWidget {
  final String vehicleId;
  final String brand;
  final String model;
  final String plateNumber;
  final String bodyType;
  final String color;
  final String rentalRate;
  final String status;

  const ViewVehicleForm({
    super.key,
    required this.vehicleId,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.bodyType,
    required this.color,
    required this.rentalRate,
    required this.status,
  });

  @override
  _ViewVehicleFormState createState() => _ViewVehicleFormState();
}

class _ViewVehicleFormState extends State<ViewVehicleForm> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 400, // Consistent width for layout
        height: 400, // Matches other forms
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Vehicle Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Divider(thickness: 1, height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildInfoTile('Vehicle ID', widget.vehicleId),
                      _buildInfoTile('Brand', widget.brand),
                      _buildInfoTile('Model', widget.model),
                      _buildInfoTile('Plate Number', widget.plateNumber),
                      _buildInfoTile('Body Type', widget.bodyType),
                      _buildInfoTile('Color', widget.color),
                      _buildInfoTile('Rental Rate', widget.rentalRate),
                      _buildInfoTile('Status', widget.status),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
