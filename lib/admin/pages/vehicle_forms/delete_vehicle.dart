import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeleteVehicleDialog extends StatefulWidget {
  final String vehicleId;
  final String vehicleModel;

  const DeleteVehicleDialog({
    super.key,
    required this.vehicleId,
    required this.vehicleModel,
  });

  @override
  _DeleteVehicleDialogState createState() => _DeleteVehicleDialogState();
}

class _DeleteVehicleDialogState extends State<DeleteVehicleDialog> {
  bool _isLoading = false;

  Future<void> _deleteVehicle() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .delete();
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Vehicle "${widget.vehicleModel}" deleted successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete vehicle.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirm Deletion"),
      content: _isLoading
          ? const SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            )
          : Text('Are you sure you want to delete "${widget.vehicleModel}"?'),
      actions: _isLoading
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: _deleteVehicle,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Delete"),
              ),
            ],
    );
  }
}
