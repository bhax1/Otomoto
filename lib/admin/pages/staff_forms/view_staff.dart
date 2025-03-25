import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ViewStaffForm extends StatefulWidget {
  final String staffId;

  const ViewStaffForm({super.key, required this.staffId});

  @override
  _ViewStaffFormState createState() => _ViewStaffFormState();
}

class _ViewStaffFormState extends State<ViewStaffForm> {
  Map<String, dynamic>? staffData;
  bool isLoading = true;
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchStaffDetails();
  }

  Future<void> _fetchStaffDetails() async {
    try {
      DocumentSnapshot staffDoc = await FirebaseFirestore.instance
          .collection('staffs')
          .doc(widget.staffId)
          .get();

      if (staffDoc.exists && staffDoc.data() != null) {
        setState(() {
          staffData = staffDoc.data() as Map<String, dynamic>;
          isLoading = false;
        });

        // Trigger opacity change separately after build
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              opacity = 1.0;
            });
          }
        });
      } else {
        setState(() {
          isLoading = false;
          staffData = null;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        staffData = null;
      });
      _showError('Error loading staff details: $error');
    }
  }

  void _showError(String message) {
    setState(() {
      isLoading = false;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pop(context); // Close the previous screen if needed
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
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
              child: staffData == null
                  ? const Center(child: Text("No data found."))
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Staff Details",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.person,
                            "Name: ${staffData!['firstname']} ${staffData!['lastname']}"),
                        _buildInfoRow(Icons.work,
                            "Job Position: ${staffData!['job_position']}"),
                        _buildInfoRow(
                            Icons.wc, "Gender: ${staffData!['gender']}"),
                        _buildInfoRow(Icons.calendar_today,
                            "Birthdate: ${_formatDate(staffData!['birthdate'])}"),
                        _buildInfoRow(Icons.calendar_today,
                            "Hire Date: ${_formatDate(staffData!['hire_date'])}"),
                        _buildInfoRow(
                            Icons.home, "Address: ${staffData!['address']}"),
                        _buildInfoRow(Icons.phone,
                            "Contact: ${staffData!['contact_num']}"),
                        _buildInfoRow(Icons.contact_emergency,
                            "Emergency Contact: ${staffData!['emergency_contact']}"),
                        _buildInfoRow(
                            Icons.email, "Email: ${staffData!['email']}"),
                        _buildInfoRow(
                          Icons.verified,
                          "Status: ${staffData!['status'] == true ? "Active" : "Inactive"}",
                          color: staffData!['status'] == true
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close",
                                style: TextStyle(color: Colors.white)),
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

  String _formatDate(String? dateString) {
    if (dateString == null) return "N/A";
    DateTime date = DateTime.parse(dateString);
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
