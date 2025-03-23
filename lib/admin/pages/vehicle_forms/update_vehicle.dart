import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpdateVehicleForm extends StatefulWidget {
  final String vehicleId;
  final String brand;
  final String model;
  final String plateNumber;
  final String bodyType;
  final String color;
  final String rentalRate;
  final String status;

  const UpdateVehicleForm({
    super.key,
    required this.vehicleId,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.bodyType,
    required this.color,
    required this.rentalRate,
    required this.status,
  });

  @override
  _UpdateVehicleFormState createState() => _UpdateVehicleFormState();
}

class _UpdateVehicleFormState extends State<UpdateVehicleForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _plateNumberController;
  late TextEditingController _bodyTypeController;
  late TextEditingController _colorController;
  late TextEditingController _rentalRateController;
  late TextEditingController _statusController;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.brand);
    _modelController = TextEditingController(text: widget.model);
    _plateNumberController = TextEditingController(text: widget.plateNumber);
    _bodyTypeController = TextEditingController(text: widget.bodyType);
    _colorController = TextEditingController(text: widget.color);
    _rentalRateController = TextEditingController(text: widget.rentalRate);
    _statusController = TextEditingController(text: widget.status);
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _plateNumberController.dispose();
    _bodyTypeController.dispose();
    _colorController.dispose();
    _rentalRateController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _updateVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    try {
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .update({
        'brand': _brandController.text,
        'model': _modelController.text,
        'plate_number': _plateNumberController.text,
        'body_type': _bodyTypeController.text,
        'color': _colorController.text,
        'rental_rate': _rentalRateController.text,
        'status': _statusController.text,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Vehicle "${widget.brand} ${widget.model}" updated successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update vehicle.")),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Update Vehicle"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField("Brand", _brandController),
              _buildTextField("Model", _modelController),
              _buildTextField("Plate Number", _plateNumberController),
              _buildTextField("Body Type", _bodyTypeController),
              _buildTextField("Color", _colorController),
              _buildTextField("Rental Rate", _rentalRateController,
                  keyboard: TextInputType.number),
              _buildTextField("Status", _statusController),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isUpdating ? null : _updateVehicle,
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
