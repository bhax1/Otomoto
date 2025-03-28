import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class MaintenanceVehicleForm extends StatefulWidget {
  final String vehicleId, brand, model, plateNumber;

  const MaintenanceVehicleForm({
    super.key,
    required this.vehicleId,
    required this.brand,
    required this.model,
    required this.plateNumber,
  });

  @override
  _MaintenanceVehicleFormState createState() => _MaintenanceVehicleFormState();
}

class _MaintenanceVehicleFormState extends State<MaintenanceVehicleForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _start, _end;
  final List<String> _selectedMaintenance = [];
  bool _isLoading = false;
  bool _showErrors = false;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime now = DateTime.now();
    DateTime firstDate = isStart ? now : (_start ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
          if (_end != null && _end!.isBefore(_start!)) _end = null;
        } else {
          _end = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (_start == null || _end == null || _selectedMaintenance.isEmpty) {
      setState(() => _showErrors = true); // Show error messages
      return;
    }

    if (!await _showConfirmationDialog()) return;

    setState(() => _isLoading = true);
    try {
      final maintenanceCollection =
          FirebaseFirestore.instance.collection('maintenance');
      final lastVehicle = await maintenanceCollection
          .orderBy('maintenance_id', descending: true)
          .limit(1)
          .get();

      final nextId = (lastVehicle.docs.isNotEmpty
              ? lastVehicle.docs.first['maintenance_id'] as int
              : 0) +
          1;

      await maintenanceCollection.add({
        'maintenance_id': nextId,
        'vehicle_id': int.tryParse(widget.vehicleId),
        'start_date': _start?.toIso8601String(),
        'end_date': _end?.toIso8601String(),
        'maintenance_type': _selectedMaintenance,
        'created_at': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'status': "Active",
      });

      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to schedule maintenance.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm Update"),
            content: const Text(
                "Are you sure you want to schedule this maintenance?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel")),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Confirm")),
            ],
          ),
        ) ??
        false;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        content: Text(
            'Maintenance for ${widget.model} ${widget.plateNumber} scheduled successfully.'),
        actions: [
          ElevatedButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text("OK")),
        ],
      ),
    );
  }

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
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Text("Maintenance Schedule",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const Text(
                    "Form for scheduling maintenance of a vehicle.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child:
                            _buildReadOnlyField("Vehicle ID", widget.vehicleId),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildReadOnlyField(
                            "Plate Number", widget.plateNumber),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildReadOnlyField("Brand", widget.brand),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildReadOnlyField("Model", widget.model),
                      ),
                    ],
                  ),
                  _buildDatePicker("Start Date", _start, true),
                  _buildDatePicker("End Date", _end, false),
                  const SizedBox(height: 12),
                  _buildMaintenanceSelection(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                          onPressed: _submitForm, child: const Text("Submit")),
                      const SizedBox(width: 10),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel")),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            date == null ? 'Select $label' : DateFormat.yMMMd().format(date),
          ),
          trailing: const Icon(Icons.calendar_today),
          onTap: () => _selectDate(context, isStart),
        ),
        if (_showErrors &&
            date == null) // Only show error after Submit is clicked
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              "Required",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildMaintenanceSelection() {
    const maintenanceOptions = ["Oil Change", "Coolant Change", "Cleaning"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Maintenance Type",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final selectedValues = await showDialog<Set<String>>(
              context: context,
              builder: (context) => MultiSelectDialog(
                options: maintenanceOptions,
                selectedValues: _selectedMaintenance.toSet(),
              ),
            );

            if (selectedValues != null) {
              setState(() {
                _selectedMaintenance.clear();
                _selectedMaintenance.addAll(selectedValues);
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
            child: Text(
              _selectedMaintenance.isEmpty
                  ? "Select Maintenance Types"
                  : _selectedMaintenance.join(", "),
              style: TextStyle(
                fontSize: 16,
                color:
                    _selectedMaintenance.isEmpty ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ),
        if (_showErrors &&
            _selectedMaintenance.isEmpty) // Only show after Submit
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 4),
            child: Text(
              "Required",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class MultiSelectDialog extends StatefulWidget {
  final List<String> options;
  final Set<String> selectedValues;

  const MultiSelectDialog(
      {required this.options, required this.selectedValues, super.key});

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late Set<String> _tempSelectedValues;

  @override
  void initState() {
    super.initState();
    _tempSelectedValues = Set.from(widget.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Maintenance Types"),
      content: SingleChildScrollView(
        child: Column(
          children: widget.options
              .map(
                (option) => CheckboxListTile(
                  title: Text(option),
                  value: _tempSelectedValues.contains(option),
                  onChanged: (selected) {
                    setState(() {
                      selected == true
                          ? _tempSelectedValues.add(option)
                          : _tempSelectedValues.remove(option);
                    });
                  },
                ),
              )
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _tempSelectedValues),
          child: const Text("Confirm"),
        ),
      ],
    );
  }
}
