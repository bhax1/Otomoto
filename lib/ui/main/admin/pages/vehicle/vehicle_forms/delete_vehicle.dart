import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DeleteVehicleDialog extends StatefulWidget {
  final String vehicleId;
  final String model, brand, plateNumber;

  const DeleteVehicleDialog({
    super.key,
    required this.vehicleId,
    required this.model,
    required this.brand,
    required this.plateNumber,
  });

  @override
  _DeleteVehicleDialogState createState() => _DeleteVehicleDialogState();
}

class _DeleteVehicleDialogState extends State<DeleteVehicleDialog> {
  bool _isLoading = false;

  Future<void> _deleteVehicle() async {
    setState(() => _isLoading = true);

    final vehicleId = int.tryParse(widget.vehicleId);

    try {
      final vehicleCollection =
          FirebaseFirestore.instance.collection('vehicles');
      final querySnapshot = await vehicleCollection
          .where('vehicle_id', isEqualTo: vehicleId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({"status": "Removed"});

        final maintenanceQuery = await FirebaseFirestore.instance
            .collection('maintenance')
            .where('vehicle_id', isEqualTo: vehicleId)
            .get();

        for (var doc in maintenanceQuery.docs) {
          await doc.reference.update({"status": "Vehicle Removed"});
        }

        if (mounted) {
          _showResultDialog("Success",
              'Vehicle "${widget.model}" deleted successfully.', Colors.green);
        }
      } else {
        if (mounted) {
          _showErrorDialog("Vehicle not found.");
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog("Failed to delete vehicle.");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text("Oops"),
            ],
          ),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

  void _confirmDeletion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Removal"),
        content: Text(
            'Are you sure you want to remove "${widget.brand} ${widget.model}" with Plate Number "${widget.plateNumber}"? \n\nThis action is irreversible and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No", style: TextStyle(color: Colors.blueGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteVehicle();
            },
            child: const Text("Yes, Cancel",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(String title, String message, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: color),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: color)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => {
              Navigator.of(context).pop(),
              Navigator.of(context).pop(),
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: AlertDialog(
        scrollable: true,
        content: _isLoading
            ? const Center(
                child: SpinKitThreeBounce(
                  color: Colors.blueGrey,
                  size: 30.0,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Confirm Vehicle Removal',
                      style: TextStyle(
                        fontSize: 20, // Make it bigger
                        fontWeight: FontWeight.bold, // Make it bold
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                        'Are you sure you want to remove "${widget.brand} ${widget.model}" with Plate Number "${widget.plateNumber}"?'),
                  ],
                ),
              ),
        actions: _isLoading
            ? null
            : [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: _confirmDeletion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text(
                    "Remove",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
      ),
    );
  }
}
