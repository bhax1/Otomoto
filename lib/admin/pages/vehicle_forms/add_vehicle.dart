import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AddVehicleForm extends StatefulWidget {
  const AddVehicleForm({super.key});

  @override
  _AddVehicleFormState createState() => _AddVehicleFormState();
}

class _AddVehicleFormState extends State<AddVehicleForm> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (await _showConfirmationDialog() != true) return;

    setState(() => _isLoading = true);
    try {
      final vehicleCollection =
          FirebaseFirestore.instance.collection('vehicles');
      final lastVehicle = await vehicleCollection
          .orderBy('vehicle_id', descending: true)
          .limit(1)
          .get();
      final nextId = (lastVehicle.docs.isNotEmpty
              ? lastVehicle.docs.first['vehicle_id'] as int
              : 0) +
          1;

      await vehicleCollection.add({
        'vehicle_id': nextId,
        'brand': _controllers[0].text,
        'model': _controllers[1].text,
        'plate_num': _controllers[2].text,
        'body_type': _controllers[3].text,
        'color': _controllers[4].text,
        'rental_rate': double.tryParse(_controllers[5].text) ?? 0,
        'created_at': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'status': "Available",
      });
      _showSuccessDialog("${_controllers[1].text} ${_controllers[2].text}");
    } catch (e) {
      _showErrorDialog("Failed to add vehicle. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showConfirmationDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Submission"),
          content: const Text("Are you sure you want to add this vehicle?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child:
                    const Text("Cancel", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Confirm",
                    style: TextStyle(color: Colors.white))),
          ],
        ),
      );

  void _showSuccessDialog(String vehicleName) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Vehicle Added Successfully!"),
          content: Text('Vehicle "$vehicleName" added successfully.'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _clearForm();
                },
                child: const Text("Add Another",
                    style: TextStyle(color: Colors.blue))),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () => {
                      Navigator.pop(context),
                      Navigator.pop(context),
                    },
                child: const Text("OK", style: TextStyle(color: Colors.white))),
          ],
        ),
      );

  void _showErrorDialog(String message) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK")),
          ],
        ),
      );

  void _clearForm() => _controllers.forEach((controller) => controller.clear());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _isLoading
          ? const SingleChildScrollView(
              child: SizedBox(
                child: Center(
                  child: SpinKitThreeBounce(
                    color: Colors.blueGrey,
                    size: 30.0,
                  ),
                ),
              ),
            )
          : Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add Vehicle",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const Text(
                    "Form for adding a staff member.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField("Brand", _controllers[0]),
                  _buildTextField("Model", _controllers[1]),
                  _buildTextField("Plate Number", _controllers[2]),
                  _buildTextField("Body Type", _controllers[3]),
                  _buildTextField("Color", _controllers[4]),
                  _buildTextField("Rental Rate", _controllers[5],
                      keyboard: TextInputType.number),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: _isLoading ? null : _submitForm,
                          child: const Text("Submit",
                              style: TextStyle(color: Colors.white))),
                      const SizedBox(width: 5),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel",
                              style: TextStyle(color: Colors.grey))),
                    ],
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}
