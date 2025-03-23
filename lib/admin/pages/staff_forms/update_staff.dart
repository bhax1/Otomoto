import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpdateStaffForm extends StatefulWidget {
  final String staffId;
  final String firstName;
  final String lastName;
  final String address;
  final String contact;
  final String email;

  const UpdateStaffForm({
    super.key,
    required this.staffId,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.contact,
    required this.email,
  });

  @override
  _UpdateStaffFormState createState() => _UpdateStaffFormState();
}

class _UpdateStaffFormState extends State<UpdateStaffForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _emailController;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
    _addressController = TextEditingController(text: widget.address);
    _contactController = TextEditingController(text: widget.contact);
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateStaff() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    try {
      await FirebaseFirestore.instance
          .collection('staffs')
          .doc(widget.staffId)
          .update({
        'firstname': _firstNameController.text,
        'lastname': _lastNameController.text,
        'address': _addressController.text,
        'contact_num': _contactController.text,
        'email': _emailController.text,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Staff "${widget.firstName} ${widget.lastName}" updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update staff.")),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Update Staff"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                    child: _buildTextField("First Name", _firstNameController)),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildTextField("Last Name", _lastNameController)),
              ],
            ),
            _buildTextField("Address", _addressController),
            _buildTextField("Contact Number", _contactController,
                keyboard: TextInputType.phone),
            _buildTextField("Email", _emailController),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isUpdating ? null : _updateStaff,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: _isUpdating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Update"),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}
