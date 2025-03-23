import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStaffForm extends StatefulWidget {
  const AddStaffForm({super.key});

  @override
  _AddStaffFormState createState() => _AddStaffFormState();
}

class _AddStaffFormState extends State<AddStaffForm> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _address = TextEditingController();
  final _contact = TextEditingController();
  final _email = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Submission"),
          content:
              const Text("Are you sure you want to add this staff member?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final staffCollection = FirebaseFirestore.instance.collection('staffs');
      final snapshot = await staffCollection
          .orderBy(FieldPath.documentId, descending: true)
          .limit(1)
          .get();
      int nextId = snapshot.docs.isEmpty
          ? 1
          : (int.tryParse(snapshot.docs.first.id) ?? -1) + 1;

      await staffCollection.doc(nextId.toString()).set({
        'firstname': _firstName.text,
        'lastname': _lastName.text,
        'address': _address.text,
        'contact_num': _contact.text,
        'password': "123",
        'email': _email.text,
        'created_at': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Show success dialog
      _showSuccessDialog("${_firstName.text} ${_lastName.text}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add staff.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String staffName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Staff Added Successfully!"),
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Staff member "$staffName" added successfully.'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearForm(); // Clear form for new entry
              },
              child: const Text("Add Another Staff"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Exit the form
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _firstName.clear();
    _lastName.clear();
    _address.clear();
    _contact.clear();
    _email.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey, // Form widget with validation
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add Staff",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text(
                "Fill out the form below to add a new staff member. Ensure all fields are completed accurately before submitting.",
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField("First Name", _firstName)),
                const SizedBox(width: 8),
                Expanded(child: _buildTextField("Last Name", _lastName)),
              ],
            ),
            _buildTextField("Address", _address),
            _buildTextField("Contact Number", _contact,
                keyboard: TextInputType.phone),
            _buildTextField("Email", _email),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(90, 40),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text("Submit",
                          style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: isPassword ? const Icon(Icons.visibility_off) : null,
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}
