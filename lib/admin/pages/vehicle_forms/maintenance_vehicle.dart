import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class MaintenanceVehicleForm extends StatefulWidget {
  final String vehicleId;

  const MaintenanceVehicleForm({super.key, required this.vehicleId});

  @override
  _MaintenanceVehicleFormState createState() => _MaintenanceVehicleFormState();
}

class _MaintenanceVehicleFormState extends State<MaintenanceVehicleForm> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleId = TextEditingController();
  final _plateNum = TextEditingController();
  final _brand = TextEditingController();
  final _model = TextEditingController();
  DateTime? _start;
  DateTime? _end;
  String? _maintenance;
  bool _isLoading = false;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchVehicleData();
  }

  Future<void> _selectDate(BuildContext context, Function(DateTime) onPicked,
      {bool isStart = false}) async {
    DateTime now = DateTime.now();
    DateTime firstDate = isStart ? now : (_start ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate, // Enforces rule: Start date must be today or later
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
          if (_end != null && _end!.isBefore(_start!)) {
            _end = null; // Reset end date if it's invalid
          }
        } else {
          _end = picked;
        }
      });
      onPicked(picked);
    }
  }

  Future<void> _fetchVehicleData() async {
    setState(() {
      _isLoading = true;
      _opacity = 0.0;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        _vehicleId.text = widget.vehicleId;
        _plateNum.text = data['plate_num'] ?? '';
        _brand.text = data['brand'] ?? '';
        _model.text = data['model'] ?? '';

        setState(() {
          _isLoading = false;
        });

        // Trigger opacity transition separately after UI rebuilds
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _opacity = 1.0;
            });
          }
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("No data found.")));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch vehicle data.")));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _start == null ||
        _end == null ||
        _maintenance == null) {
      return;
    }

    bool? confirm = await _showConfirmationDialog();
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final vehicleCollection =
          FirebaseFirestore.instance.collection('maintenance');
      final snapshot = await vehicleCollection
          .orderBy(FieldPath.documentId, descending: true)
          .limit(1)
          .get();

      int nextId = snapshot.docs.isEmpty
          ? 1
          : (int.tryParse(snapshot.docs.first.id) ?? -1) + 1;

      await vehicleCollection.doc(nextId.toString()).set({
        'vehicle_id': "1",
        'start_date': _start?.toIso8601String(),
        'end_date': _end?.toIso8601String(),
        'maintenance_type': _maintenance,
        'created_at': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .update({
        'status': "Under Maintenance",
      });

      _showSuccessDialog("${_model.text} ${_plateNum.text}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to schedule maintenance.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Update"),
        content: const Text(
            "Are you sure you want to schedule a maintenance on this vehicle?"),
        actions: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
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
      builder: (context) => AlertDialog(
        title: const Text("Staff Updated Successfully!"),
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
                child: Text(
                    'Vehicle maintenance for "$vehicleName" scheduled successfully.')),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("OK"),
          ),
        ],
      ),
    );
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
                      const Text("Maintenance Schedule",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      const Text(
                        "Form for scheduling maintenance of a vehicle.",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField("Vehicle ID", _vehicleId,
                                readOnly: true),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _buildTextField("Plate Number", _plateNum,
                                  readOnly: true)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField("Brand", _brand,
                                readOnly: true),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _buildTextField("Model", _model,
                                  readOnly: true)),
                        ],
                      ),
                      const Text(
                        "Start",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      _buildDatePickerField("Start", _start,
                          (date) => setState(() => _start = date),
                          isStart: true),
                      const Text(
                        "End",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      _buildDatePickerField(
                          "End", _end, (date) => setState(() => _end = date)),
                      _buildMaintenanceDropdown(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                minimumSize: const Size(90, 40)),
                            child: const Text("Submit",
                                style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel",
                                style: TextStyle(color: Colors.grey)),
                          ),
                        ],
                      )
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

  Widget _buildDatePickerField(
      String label, DateTime? date, Function(DateTime) onPicked,
      {bool isStart = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(
            date == null ? 'Select $label' : DateFormat.yMMMd().format(date)),
        trailing: const Icon(Icons.calendar_today),
        onTap: () => _selectDate(context, onPicked, isStart: isStart),
      ),
    );
  }

  Widget _buildMaintenanceDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: _maintenance,
        decoration: const InputDecoration(
            labelText: "Maintenance Type", border: OutlineInputBorder()),
        items: ["Oil Change", "Coolant Change", "Cleaning"]
            .map((gender) =>
                DropdownMenuItem(value: gender, child: Text(gender)))
            .toList(),
        onChanged: (value) => setState(() => _maintenance = value),
        validator: (value) => value == null ? 'Required' : null,
      ),
    );
  }
}
