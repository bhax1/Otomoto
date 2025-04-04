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

    final staffId = int.tryParse(widget.staffId);

    try {
      final staffCollection = FirebaseFirestore.instance.collection('staffs');
      final querySnapshot =
          await staffCollection.where('staff_id', isEqualTo: staffId).get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({"status": "Removed"});

        if (mounted) {
          _showResultDialog(
              "Success",
              'Staff "${widget.staffName}" deleted successfully.',
              Colors.green);
        }
      } else {
        if (mounted) {
          _showErrorDialog("Staff not found.");
        }
      }
    } catch (e) {
      if (mounted) {
        if (mounted) {
          _showErrorDialog("Failed to delete staff.");
        }
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
            'Are you sure you want to delete "${widget.staffName}"? \n\nThis action is irreversible and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No", style: TextStyle(color: Colors.blueGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _deleteStaff();
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
              Navigator.pop(context),
              Navigator.pop(context),
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
                      'Confirm Staff Removal',
                      style: TextStyle(
                        fontSize: 20, // Make it bigger
                        fontWeight: FontWeight.bold, // Make it bold
                      ),
                    ),
                    const SizedBox(height: 20),
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
                        onPressed: _confirmDeletion,
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
      ),
    );
  }
}
