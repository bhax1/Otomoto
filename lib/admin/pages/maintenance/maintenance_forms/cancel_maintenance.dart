import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class CancelMaintenanceForm extends StatefulWidget {
  final int vehicleId;
  final int maintenanceId;

  const CancelMaintenanceForm({
    super.key,
    required this.maintenanceId,
    required this.vehicleId,
  });

  @override
  _CancelMaintenanceFormState createState() => _CancelMaintenanceFormState();
}

class _CancelMaintenanceFormState extends State<CancelMaintenanceForm> {
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

  void _confirmCancellation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Cancellation"),
        content: const Text(
            "Are you sure you want to cancel this maintenance request?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No", style: TextStyle(color: Colors.blueGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _cancelMaintenance();
            },
            child: const Text("Yes, Cancel",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelMaintenance() async {
    try {
      final maintenanceQuery = await FirebaseFirestore.instance
          .collection('maintenance')
          .where("maintenance_id", isEqualTo: widget.maintenanceId)
          .limit(1)
          .get();

      if (maintenanceQuery.docs.isNotEmpty) {
        await maintenanceQuery.docs.first.reference
            .update({"status": "Cancelled"});
        if (mounted) Navigator.pop(context, 'Cancelled');
      }
    } catch (error) {
      _showError('Failed to cancel maintenance: $error');
    }
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      contentPadding: const EdgeInsets.all(24),
      scrollable: true,
      content: isLoading
          ? const Center(
              child: SpinKitThreeBounce(color: Colors.blueGrey, size: 30.0))
          : AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              opacity: opacity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Cancel Maintenance",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[900])),
                  const SizedBox(height: 12),
                  Text(
                      "Are you sure you want to cancel this maintenance request?",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.grey[700])),
                  const SizedBox(height: 20),
                  _buildInfoSection(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      children: [
        _buildInfoRow(
            Icons.car_rental, "Brand: ${vehicleData?['brand'] ?? 'N/A'}"),
        _buildInfoRow(
            Icons.directions_car, "Model: ${vehicleData?['model'] ?? 'N/A'}"),
        _buildInfoRow(
            Icons.palette, "Color: ${vehicleData?['color'] ?? 'N/A'}"),
        _buildInfoRow(Icons.confirmation_number,
            "Plate Number: ${vehicleData?['plate_number'] ?? 'N/A'}"),
        const Divider(),
        _buildInfoRow(
            Icons.settings, "Maintenance Type: ${_getMaintenanceTypes()}"),
        _buildInfoRow(Icons.date_range,
            "Start Date: ${_formatDate(maintenanceData?['start_date'])}"),
        _buildInfoRow(Icons.event,
            "End Date: ${_formatDate(maintenanceData?['end_date'])}"),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Dismiss", style: TextStyle(color: Colors.grey[600])),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
          onPressed: _confirmCancellation,
          child: const Text("Cancel Request"),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, color: Colors.blueGrey),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)))
      ]),
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
