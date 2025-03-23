import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddVehicleForm extends StatefulWidget {
  const AddVehicleForm({super.key});

  @override
  _AddVehicleFormState createState() => _AddVehicleFormState();
}

class _AddVehicleFormState extends State<AddVehicleForm> {
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _plateNum = TextEditingController();
  final _bodyType = TextEditingController();
  final _color = TextEditingController();
  final _rentalRate = TextEditingController();
  final _status = TextEditingController();
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
          content: const Text("Are you sure you want to add this vehicle?"),
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
      final vehicleCollection =
          FirebaseFirestore.instance.collection('vehicles');
      final snapshot = await vehicleCollection
          .orderBy(FieldPath.documentId, descending: true)
          .limit(1)
          .get();
      int nextId = snapshot.docs.isEmpty
          ? 1
          : (int.tryParse(snapshot.docs.first.id) ?? -1) + 1;

      await vehicleCollection.doc(nextId.toString()).set({
        'brand': _brand.text,
        'model': _model.text,
        'plate_num': _plateNum.text,
        'body_type': _bodyType.text,
        'color': _color.text,
        'rental_rate': int.tryParse(_rentalRate.text) ?? 0,
        'status': _status.text,
        'created_at': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      _showSuccessDialog("${_brand.text} ${_model.text}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add vehicle.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(String vehicleName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Vehicle Added Successfully!"),
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Vehicle "$vehicleName" added successfully.'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearForm();
              },
              child: const Text("Add Another Vehicle"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
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
    _brand.clear();
    _model.clear();
    _plateNum.clear();
    _bodyType.clear();
    _color.clear();
    _rentalRate.clear();
    _status.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add Vehicle",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text(
                "Fill out the form below to add a new vehicle. Ensure all fields are completed accurately before submitting.",
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField("Brand", _brand)),
                const SizedBox(width: 8),
                Expanded(child: _buildTextField("Model", _model)),
              ],
            ),
            _buildTextField("Plate Number", _plateNum),
            _buildTextField("Body Type", _bodyType),
            _buildTextField("Color", _color),
            _buildTextField("Rental Rate", _rentalRate,
                keyboard: TextInputType.number),
            _buildTextField("Status", _status),
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
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}
