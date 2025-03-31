import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class UpdateStaffForm extends StatefulWidget {
  final String staffId;

  const UpdateStaffForm({super.key, required this.staffId});

  @override
  _UpdateStaffFormState createState() => _UpdateStaffFormState();
}

class _UpdateStaffFormState extends State<UpdateStaffForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _address = TextEditingController();
  final _contact = TextEditingController();
  final _email = TextEditingController();
  final _jobPosition = TextEditingController();
  final _emergencyContact = TextEditingController();
  DateTime? _birthdate;
  DateTime? _hireDate;
  String? _gender;
  bool? _status;
  bool _isLoading = false;
  double _opacity = 0.0;
  Map<String, dynamic> _initialValues = {};

  @override
  void initState() {
    super.initState();
    _fetchStaffData();

    // Add listeners to text fields
    _firstName.addListener(() => setState(() {}));
    _lastName.addListener(() => setState(() {}));
    _address.addListener(() => setState(() {}));
    _contact.addListener(() => setState(() {}));
    _email.addListener(() => setState(() {}));
    _jobPosition.addListener(() => setState(() {}));
    _emergencyContact.addListener(() => setState(() {}));
  }

  Future<void> _selectDate(
      BuildContext context, Function(DateTime) onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _fetchStaffData() async {
    setState(() {
      _isLoading = true;
      _opacity = 0.0;
    });

    try {
      final staffId = int.tryParse(widget.staffId);
      if (staffId == null) throw Exception('Invalid staff ID');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('staffs')
          .where("staff_id", isEqualTo: staffId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();

        _firstName.text = data['firstname'] ?? '';
        _lastName.text = data['lastname'] ?? '';
        _address.text = data['address'] ?? '';
        _contact.text = data['contact_num'] ?? '';
        _email.text = data['email'] ?? '';
        _jobPosition.text = data['job_position'] ?? '';
        _emergencyContact.text = data['emergency_contact'] ?? '';
        _birthdate = data['birthdate'] != null
            ? DateTime.tryParse(data['birthdate'])
            : null;
        _hireDate = data['hire_date'] != null
            ? DateTime.tryParse(data['hire_date'])
            : null;
        _gender = data['gender'];
        _status = data['status'];

        _initialValues = {
          'firstname': _firstName.text,
          'lastname': _lastName.text,
          'address': _address.text,
          'contact_num': _contact.text,
          'email': _email.text,
          'job_position': _jobPosition.text,
          'emergency_contact': _emergencyContact.text,
          'birthdate': _birthdate?.toIso8601String(),
          'hire_date': _hireDate?.toIso8601String(),
          'gender': _gender,
          'status': _status,
        };

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to fetch staff data: ${e.toString()}")));
    }
  }

  Future<void> _updateStaff() async {
    if (!_formKey.currentState!.validate() ||
        _birthdate == null ||
        _hireDate == null ||
        _gender == null) {
      return;
    }

    bool? confirm = await _showConfirmationDialog();
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final staffCollection = FirebaseFirestore.instance.collection('staffs');
      final staffId = int.tryParse(widget.staffId);

      final querySnapshot = await staffCollection
          .where('staff_id', isEqualTo: staffId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await staffCollection.doc(querySnapshot.docs.first.id).update({
          'firstname': _firstName.text,
          'lastname': _lastName.text,
          'address': _address.text,
          'contact_num': _contact.text,
          'email': _email.text,
          'job_position': _jobPosition.text,
          'birthdate': _birthdate?.toIso8601String(),
          'hire_date': _hireDate?.toIso8601String(),
          'gender': _gender,
          'status': _status,
          'emergency_contact': _emergencyContact.text,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
      _showSuccessDialog("${_firstName.text} ${_lastName.text}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update staff.")),
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
        content:
            const Text("Are you sure you want to update this staff member?"),
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

  void _showSuccessDialog(String staffName) {
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
                child: Text('Staff member "$staffName" updated successfully.')),
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

  bool _hasChanges() {
    return _firstName.text != _initialValues['firstname'] ||
        _lastName.text != _initialValues['lastname'] ||
        _address.text != _initialValues['address'] ||
        _contact.text != _initialValues['contact_num'] ||
        _email.text != _initialValues['email'] ||
        _jobPosition.text != _initialValues['job_position'] ||
        _emergencyContact.text != _initialValues['emergency_contact'] ||
        _birthdate?.toIso8601String() != _initialValues['birthdate'] ||
        _hireDate?.toIso8601String() != _initialValues['hire_date'] ||
        _gender != _initialValues['gender'] ||
        _status != _initialValues['status'];
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
                        const Text("Update Staff",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        const Text(
                          "Form for updating details of a staff member.",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Staff ID: ${widget.staffId}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                                child:
                                    _buildTextField("First Name", _firstName)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: _buildTextField("Last Name", _lastName)),
                          ],
                        ),
                        _buildTextField("Address", _address),
                        _buildTextField("Contact Number", _contact,
                            keyboard: TextInputType.phone),
                        _buildTextField("Email", _email),
                        _buildTextField("Job Position", _jobPosition),
                        _buildTextField("Emergency Contact", _emergencyContact,
                            keyboard: TextInputType.phone),
                        const Text(
                          "Birthdate",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        _buildDatePickerField("Birthdate", _birthdate,
                            (date) => setState(() => _birthdate = date)),
                        const Text(
                          "Hire Date",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        _buildDatePickerField("Hire Date", _hireDate,
                            (date) => setState(() => _hireDate = date)),
                        _buildGenderDropdown(),
                        SwitchListTile(
                          title: const Text("Active Status"),
                          value: _status ?? true,
                          onChanged: (value) {
                            setState(() {
                              _status = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: _hasChanges() ? _updateStaff : null,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _hasChanges() ? Colors.blue : Colors.grey,
                                  minimumSize: const Size(90, 40)),
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
                        )
                      ],
                    ),
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
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildDatePickerField(
      String label, DateTime? date, Function(DateTime) onPicked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(
            date == null ? 'Select $label' : DateFormat.yMMMd().format(date)),
        trailing: const Icon(Icons.calendar_today),
        onTap: () => _selectDate(context, onPicked),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: _gender,
        decoration: const InputDecoration(
            labelText: "Gender", border: OutlineInputBorder()),
        items: ["Male", "Female", "Other"]
            .map((gender) =>
                DropdownMenuItem(value: gender, child: Text(gender)))
            .toList(),
        onChanged: (value) => setState(() => _gender = value),
        validator: (value) => value == null ? 'Required' : null,
      ),
    );
  }
}
