import 'package:flutter/material.dart';

class ViewStaffForm extends StatefulWidget {
  final String staffId;
  final String name;
  final String address;
  final String contact;
  final String email;

  const ViewStaffForm({
    super.key,
    required this.staffId,
    required this.name,
    required this.address,
    required this.contact,
    required this.email,
  });

  @override
  _ViewStaffFormState createState() => _ViewStaffFormState();
}

class _ViewStaffFormState extends State<ViewStaffForm> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 400, // Ensures a consistent width like AddStaffForm
        height: 400, // Matches the height of AddStaffForm
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Staff Details',
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
                      _buildInfoTile('ID', widget.staffId),
                      _buildInfoTile('Full Name', widget.name),
                      _buildInfoTile('Address', widget.address),
                      _buildInfoTile('Contact', widget.contact),
                      _buildInfoTile('Email', widget.email),
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
