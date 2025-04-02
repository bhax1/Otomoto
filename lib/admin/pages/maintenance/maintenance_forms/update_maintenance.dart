import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UpdateMaintenanceForm extends StatefulWidget {
  final int vehicleId;
  final int maintenanceId;

  const UpdateMaintenanceForm({
    super.key,
    required this.maintenanceId,
    required this.vehicleId,
  });

  @override
  _UpdateMaintenanceFormState createState() => _UpdateMaintenanceFormState();
}

class _UpdateMaintenanceFormState extends State<UpdateMaintenanceForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _start, _end;
  List<String> _selectedMaintenance = [];
  bool _isLoading = true;
  bool _showErrors = false;
  Map<String, dynamic>? vehicleData;
  Map<String, dynamic>? maintenanceData;
  Map<String, dynamic>? _initialMaintenanceData;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  bool _hasChanges() {
    if (_initialMaintenanceData == null) return false;

    return _start?.toIso8601String() !=
            _initialMaintenanceData!['start_date'] ||
        _end?.toIso8601String() != _initialMaintenanceData!['end_date'] ||
        _selectedMaintenance.toSet().toString() !=
            (_initialMaintenanceData!['maintenance_type'] as List<dynamic>?)
                ?.toSet()
                .toString();
  }

  Future<void> _fetchData() async {
    try {
      vehicleData = await _fetchVehicleData();
      maintenanceData = await _fetchMaintenanceData();

      if (maintenanceData != null) {
        _initialMaintenanceData = Map<String, dynamic>.from(maintenanceData!);
      }

      if (mounted) {
        setState(() {
          // Pre-fill fields
          if (maintenanceData != null) {
            _start = (maintenanceData!['start_date'] != null)
                ? DateTime.parse(maintenanceData!['start_date'])
                : null;
            _end = (maintenanceData!['end_date'] != null)
                ? DateTime.parse(maintenanceData!['end_date'])
                : null;
            _selectedMaintenance =
                List<String>.from(maintenanceData!['maintenance_type'] ?? []);
          }

          _isLoading = false;
        });
      }
    } catch (error) {
      _showErrorDialog('Failed to load details: $error');
    }
  }

  Future<Map<String, dynamic>?> _fetchVehicleData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('vehicles')
        .where("vehicle_id", isEqualTo: widget.vehicleId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty ? snapshot.docs.first.data() : null;
  }

  Future<Map<String, dynamic>?> _fetchMaintenanceData() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('maintenance')
        .where("maintenance_id", isEqualTo: widget.maintenanceId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty ? snapshot.docs.first.data() : null;
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_start ?? DateTime.now())
          : (_end ?? _start ?? DateTime.now()),
      firstDate: DateTime(2020),
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
      setState(() => _showErrors = true);
      return;
    }

    if (!await _showConfirmationDialog()) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('maintenance')
          .where("maintenance_id", isEqualTo: widget.maintenanceId)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.first.reference.update({
            'start_date': _start!.toIso8601String(),
            'end_date': _end!.toIso8601String(),
            'maintenance_type': _selectedMaintenance,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });

      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog("Failed to update maintenance: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm Update"),
            content:
                const Text("Are you sure you want to update this maintenance?"),
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

  void _showErrorDialog(String message) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text("Oops"),
            ],
          ),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

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
        if (_showErrors && date == null)
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text("Required",
                style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildMaintenanceSelection() {
    const maintenanceOptions = ["Oil Change", "Coolant Change", "Cleaning"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Maintenance Type",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                _selectedMaintenance = selectedValues.toList();
              });
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
            child: Text(
              _selectedMaintenance.isEmpty
                  ? "Select Maintenance Types"
                  : _selectedMaintenance.join(", "),
              style: TextStyle(
                  fontSize: 16,
                  color: _selectedMaintenance.isEmpty
                      ? Colors.grey
                      : Colors.black),
            ),
          ),
        ),
        if (_showErrors && _selectedMaintenance.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 4),
            child: Text("Required",
                style: TextStyle(color: Colors.red, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        content: const Text('Maintenance updated successfully.'),
        actions: [
          ElevatedButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: Padding(
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
                    const Text("Update Maintenance Schedule",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    const Text(
                      "Form for updating maintenance of a vehicle.",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: _buildReadOnlyField(
                              "Vehicle ID", widget.vehicleId.toString()),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildReadOnlyField("Plate Number",
                              vehicleData?['plate_number'] ?? 'N/A'),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildReadOnlyField(
                              "Brand", vehicleData?['brand'] ?? 'N/A'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildReadOnlyField(
                              "Model", vehicleData?['model'] ?? 'N/A'),
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
                          onPressed: _hasChanges() ? _submitForm : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _hasChanges() ? Colors.blue : Colors.grey,
                          ),
                          child: const Text("Update",
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 10),
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
                  activeColor: Colors.green,
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
          onPressed: () => Navigator.pop(context),
          child: const Text("Dismiss", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _tempSelectedValues),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: const Text("Confirm", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
