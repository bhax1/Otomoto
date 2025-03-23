import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeleteStaffDialog extends StatefulWidget {
  final String staffId;
  final String staffName;

  const DeleteStaffDialog({
    super.key,
    required this.staffId,
    required this.staffName,
  });

  @override
  _DeleteStaffDialogState createState() => _DeleteStaffDialogState();
}

class _DeleteStaffDialogState extends State<DeleteStaffDialog> {
  bool _isLoading = false;

  Future<void> _deleteStaff() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('staffs')
          .doc(widget.staffId)
          .delete();
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Staff "${widget.staffName}" deleted successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete staff.")),
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
          : Text('Are you sure you want to delete "${widget.staffName}"?'),
      actions: _isLoading
          ? []
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: _deleteStaff,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Delete"),
              ),
            ],
    );
  }
}
