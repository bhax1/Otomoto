import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UpdateVehicleForm extends StatefulWidget {
  final String vehicleId;

  const UpdateVehicleForm({super.key, required this.vehicleId});

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
  String? _status;
  bool _isUpdating = false;
  bool _isLoading = true;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController();
    _modelController = TextEditingController();
    _plateNumberController = TextEditingController();
    _bodyTypeController = TextEditingController();
    _colorController = TextEditingController();
    _rentalRateController = TextEditingController();
    _fetchVehicleDetails();
  }

  Future<void> _fetchVehicleDetails() async {
    setState(() {
      _isLoading = true;
      _opacity = 0.0;
    });

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _brandController.text = data['brand'] ?? '';
          _modelController.text = data['model'] ?? '';
          _plateNumberController.text = data['plate_number'] ?? '';
          _bodyTypeController.text = data['body_type'] ?? '';
          _colorController.text = data['color'] ?? '';
          _rentalRateController.text = data['rental_rate']?.toString() ?? '';
          _status = data['status'] ?? '';
        });
      }

      setState(() {
        _isLoading = false;
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _opacity = 1.0;
          });
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load vehicle details.")),
      );
      setState(() => _isLoading = false);
    }
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
        'rental_rate': double.tryParse(_rentalRateController.text) ?? 0,
        'status': _status,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Vehicle "${_brandController.text} ${_modelController.text}" updated successfully')),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: _isLoading
          ? SingleChildScrollView(
              child: SizedBox(
                child: const Center(
                  child: SpinKitThreeBounce(
                    color: Colors.blueGrey,
                    size: 30.0,
                  ),
                ),
              ),
            )
          : AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              opacity: _opacity,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Update Vehicle",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      const Text(
                        "Form for updating details of a vehicle.",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Vehicle ID: ${widget.vehicleId}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 5),
                      _buildTextField("Brand", _brandController),
                      _buildTextField("Model", _modelController),
                      _buildTextField("Plate Number", _plateNumberController),
                      _buildTextField("Body Type", _bodyTypeController),
                      _buildTextField("Color", _colorController),
                      _buildTextField("Rental Rate", _rentalRateController,
                          keyboard: TextInputType.number),
                      _buildDropdownField("Status", _status, [
                        "Available",
                        "Unavailable",
                      ]),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: _isUpdating ? null : _updateVehicle,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue),
                            child: _isUpdating
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
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
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        readOnly: readOnly,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: (newValue) => setState(() => _status = newValue),
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
        items: items.map((status) {
          return DropdownMenuItem(value: status, child: Text(status));
        }).toList(),
      ),
    );
  }
}
