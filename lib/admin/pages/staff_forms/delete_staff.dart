import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
                    'Confirm Deletion',
                    style: TextStyle(
                      fontSize: 20, // Make it bigger
                      fontWeight: FontWeight.bold, // Make it bold
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      'Are you sure you want to delete "${widget.staffName}"?'),
                ],
              ),
            ),
      actions: _isLoading
          ? null
          : [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _deleteStaff,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
    );
  }
}
