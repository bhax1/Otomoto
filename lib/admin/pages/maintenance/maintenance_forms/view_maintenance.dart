import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class ViewMaintenanceForm extends StatefulWidget {
  final int vehicleId;
  final int maintenanceId;

  const ViewMaintenanceForm({
    super.key,
    required this.maintenanceId,
    required this.vehicleId,
  });

  @override
  _ViewMaintenanceFormState createState() => _ViewMaintenanceFormState();
}

class _ViewMaintenanceFormState extends State<ViewMaintenanceForm> {
  Map<String, dynamic>? vehicleData;
  Map<String, dynamic>? maintenanceData;
  bool isLoading = true;
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final results = await Future.wait([
        _fetchVehicleData(),
        _fetchMaintenanceData(),
      ]);

      if (mounted) {
        setState(() {
          vehicleData = results[0];
          maintenanceData = results[1];
          isLoading = false;
        });

        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() => opacity = 1.0);
        });
      }
    } catch (error) {
      _showError('Failed to load details: $error');
    }
  }

  Future<Map<String, dynamic>?> _fetchVehicleData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('vehicles')
        .where("vehicle_id", isEqualTo: widget.vehicleId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty ? snapshot.docs.first.data() : null;
  }

  Future<Map<String, dynamic>?> _fetchMaintenanceData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('maintenance')
        .where("maintenance_id", isEqualTo: widget.maintenanceId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty ? snapshot.docs.first.data() : null;
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => isLoading = false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: isLoading
          ? const Center(
              child: SpinKitThreeBounce(
                color: Colors.blueGrey,
                size: 30.0,
              ),
            )
          : AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              opacity: opacity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Vehicle Details",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.car_rental,
                      "Brand: ${vehicleData?['brand'] ?? 'N/A'}"),
                  _buildInfoRow(Icons.directions_car,
                      "Model: ${vehicleData?['model'] ?? 'N/A'}"),
                  _buildInfoRow(Icons.palette,
                      "Color: ${vehicleData?['color'] ?? 'N/A'}"),
                  _buildInfoRow(Icons.confirmation_number,
                      "Plate Number: ${vehicleData?['plate_number'] ?? 'N/A'}"),
                  const Divider(),
                  _buildInfoRow(Icons.settings,
                      "Maintenance Type: ${_getMaintenanceTypes()}"),
                  _buildInfoRow(Icons.date_range,
                      "Start Date: ${_formatDate(maintenanceData?['start_date'])}"),
                  _buildInfoRow(Icons.event,
                      "End Date: ${_formatDate(maintenanceData?['end_date'])}"),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Close",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMaintenanceTypes() =>
      maintenanceData?['maintenance_type']?.join(", ") ?? "N/A";

  String _formatDate(dynamic date) {
    if (date == null) return "N/A";
    if (date is Timestamp) {
      return DateFormat('MMMM d, y').format(date.toDate());
    } else if (date is String) {
      try {
        DateTime parsedDate = DateTime.parse(date);
        return DateFormat('MMMM d, y').format(parsedDate);
      } catch (e) {
        return "Invalid Date";
      }
    }
    return "N/A";
  }
}
