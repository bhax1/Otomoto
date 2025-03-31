import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UpdateVehicleForm extends StatefulWidget {
  final String vehicleId;
  final String brand, model, plateNumber, bodyType, color, status;
  final double rentalRate;

  const UpdateVehicleForm({
    super.key,
    required this.vehicleId,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.bodyType,
    required this.color,
    required this.status,
    required this.rentalRate,
  });

  @override
  _UpdateVehicleFormState createState() => _UpdateVehicleFormState();
}

class _UpdateVehicleFormState extends State<UpdateVehicleForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _plateNumberController;
  late final TextEditingController _bodyTypeController;
  late final TextEditingController _colorController;
  late final TextEditingController _rentalRateController;
  String? _status;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController(text: widget.brand)
      ..addListener(_onFieldChanged);
    _modelController = TextEditingController(text: widget.model)
      ..addListener(_onFieldChanged);
    _plateNumberController = TextEditingController(text: widget.plateNumber)
      ..addListener(_onFieldChanged);
    _bodyTypeController = TextEditingController(text: widget.bodyType)
      ..addListener(_onFieldChanged);
    _colorController = TextEditingController(text: widget.color)
      ..addListener(_onFieldChanged);
    _rentalRateController =
        TextEditingController(text: widget.rentalRate.toString())
          ..addListener(_onFieldChanged);
    _status = widget.status;
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _plateNumberController.dispose();
    _bodyTypeController.dispose();
    _colorController.dispose();
    _rentalRateController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    setState(() {});
  }

  bool _hasChanges() {
    return _brandController.text != widget.brand ||
        _modelController.text != widget.model ||
        _plateNumberController.text != widget.plateNumber ||
        _bodyTypeController.text != widget.bodyType ||
        _colorController.text != widget.color ||
        _rentalRateController.text != widget.rentalRate.toString() ||
        _colorController.text != widget.color ||
        _rentalRateController.text != widget.rentalRate.toString() ||
        _status != widget.status;
  }

  Future<void> _updateVehicle() async {
    bool? confirm = await _showConfirmationDialog();
    if (confirm != true) return;

    if (!_formKey.currentState!.validate()) return;
    setState(() => _isUpdating = true);

    try {
      final vehicleCollection =
          FirebaseFirestore.instance.collection('vehicles');
      final vehicleId = int.tryParse(widget.vehicleId);
      if (vehicleId == null) {
        _showErrorDialog("Invalid vehicle ID.");
        return;
      }

      final querySnapshot = await vehicleCollection
          .where('vehicle_id', isEqualTo: vehicleId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await vehicleCollection.doc(querySnapshot.docs.first.id).update({
          'brand': _brandController.text,
          'model': _modelController.text,
          'plate_number': _plateNumberController.text,
          'body_type': _bodyTypeController.text,
          'color': _colorController.text,
          'rental_rate': double.tryParse(_rentalRateController.text) ?? 0,
          'status': _status,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        _showSuccessDialog(
            "${_brandController.text} ${_modelController.text} - ${_plateNumberController.text}");
      } else {
        _showErrorDialog("Vehicle not found.");
      }
    } catch (e) {
      _showErrorDialog("Failed to update vehicle.");
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Submission"),
        content: const Text("Are you sure you want to add this vehicle?"),
        actions: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text("Confirm", style: TextStyle(color: Colors.white))),
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  void _showSuccessDialog(String vehicleName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Vehicle Updated Successfully!"),
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Vehicle "$vehicleName" updated successfully.'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isUpdating,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _isUpdating
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
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Text("Update Vehicle",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    const Text("Form for updating vehicle details.",
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Text("Vehicle ID: ${widget.vehicleId}",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green)),
                    const SizedBox(height: 5),
                    _buildTextField("Brand", _brandController),
                    _buildTextField("Model", _modelController),
                    _buildTextField("Plate Number", _plateNumberController),
                    _buildTextField("Body Type", _bodyTypeController),
                    _buildTextField("Color", _colorController),
                    _buildTextField("Rental Rate", _rentalRateController,
                        keyboard: TextInputType.number),
                    _buildDropdownField(
                        "Status", _status, ["Available", "Unavailable"]),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: (_isUpdating || !_hasChanges())
                              ? null
                              : _updateVehicle,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          child: _isUpdating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Text("Update",
                                  style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 5),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel",
                              style: TextStyle(color: Colors.grey)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: (newValue) {
          setState(() {
            _status = newValue;
          });
        },
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
        items: items
            .map((status) =>
                DropdownMenuItem(value: status, child: Text(status)))
            .toList(),
      ),
    );
  }
}
