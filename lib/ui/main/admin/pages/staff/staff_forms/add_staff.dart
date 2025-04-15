import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AddStaffForm extends StatefulWidget {
  const AddStaffForm({super.key});

  @override
  _AddStaffFormState createState() => _AddStaffFormState();
}

class _AddStaffFormState extends State<AddStaffForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _address = TextEditingController();
  final _contact = TextEditingController();
  final _email = TextEditingController();
  final _emergencyContact = TextEditingController();
  DateTime? _birthdate;
  DateTime? _hireDate;
  String? _gender;
  bool _isLoading = false;

  final List<int> _selectedRoleIds = [];
  Map<int, String> _availableRoles = {};

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    final roleSnap = await FirebaseFirestore.instance.collection('role').get();
    final roles = {
      for (var doc in roleSnap.docs) int.parse(doc.id): doc['name'] as String,
    };
    setState(() {
      _availableRoles = roles;
    });
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _birthdate == null ||
        _hireDate == null ||
        _gender == null ||
        _selectedRoleIds.isEmpty) {
      _showErrorDialog(
          "Please fill all required fields including at least one role.");
      return;
    }

    bool? confirm = await _showConfirmationDialog();
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final staffCollection = FirebaseFirestore.instance.collection('staffs');
      final lastStaff = await staffCollection
          .orderBy('staff_id', descending: true)
          .limit(1)
          .get();
      final nextId = (lastStaff.docs.isNotEmpty
              ? lastStaff.docs.first['staff_id'] as int
              : 0) +
          1;

      await staffCollection.add({
        'auth_id': "",
        'staff_id': nextId,
        'email': _email.text,
        'username': "", // You may add logic to generate or input username
        'created_at': FieldValue.serverTimestamp(),
        'last_updated': FieldValue.serverTimestamp(),
        'status': "Active",
        'roles': _selectedRoleIds,
      });

      final staffProfileCollection =
          FirebaseFirestore.instance.collection('staff_profiles');

      await staffProfileCollection.add({
        'staff_id': nextId,
        'firstname': _firstName.text,
        'lastname': _lastName.text,
        'address': _address.text,
        'contact_num': _contact.text,
        'birth_date': _birthdate?.toIso8601String(),
        'hire_date': _hireDate?.toIso8601String(),
        'gender': _gender,
        'emergency_contact': _emergencyContact.text,
      });

      _showSuccessDialog("${_firstName.text} ${_lastName.text}");
    } catch (e) {
      _showErrorDialog("Failed to add staff.");
    } finally {
      setState(() => _isLoading = false);
    }
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

  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Submission"),
        content: const Text("Are you sure you want to add this staff member?"),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String staffName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
              Navigator.pop(context);
              _clearForm();
            },
            child: const Text("Add Another"),
          ),
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

  void _clearForm() {
    _firstName.clear();
    _lastName.clear();
    _address.clear();
    _contact.clear();
    _email.clear();
    _emergencyContact.clear();
    _birthdate = null;
    _hireDate = null;
    _gender = null;
    _selectedRoleIds.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(
                child: SpinKitThreeBounce(
                  color: Colors.blueGrey,
                  size: 30.0,
                ),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Add Staff",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      const Text(
                        "Fill out the form below to add a new staff member.",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                              child: _buildTextField("First Name", _firstName)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _buildTextField("Last Name", _lastName)),
                        ],
                      ),
                      _buildTextField("Address", _address),
                      _buildTextField("Contact Number", _contact,
                          keyboard: TextInputType.phone),
                      _buildTextField("Email", _email),
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
                      const SizedBox(height: 12),
                      _buildRoleMultiSelect(),
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
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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

  Widget _buildRoleMultiSelect() {
    const bookingManagerId = 2;
    const bookingStaffId = 3;
    const adminRoleId = 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Assign Roles",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: _availableRoles.entries
              .where((entry) => entry.key != adminRoleId) // 🚫 Exclude Admin
              .map((entry) {
            final roleId = entry.key;
            final roleName = entry.value;
            final isSelected = _selectedRoleIds.contains(roleId);

            // Disable logic
            bool isDisabled = false;
            if (roleId == bookingStaffId &&
                _selectedRoleIds.contains(bookingManagerId)) {
              isDisabled = true;
            } else if (roleId == bookingManagerId &&
                _selectedRoleIds.contains(bookingStaffId)) {
              isDisabled = true;
            }

            return FilterChip(
              label: Text(roleName),
              selected: isSelected,
              onSelected: isDisabled
                  ? null
                  : (selected) {
                      setState(() {
                        if (selected) {
                          _selectedRoleIds.add(roleId);
                        } else {
                          _selectedRoleIds.remove(roleId);
                        }
                      });
                    },
              selectedColor: Colors.blue,
              checkmarkColor: Colors.white,
              disabledColor: Colors.grey.shade300,
            );
          }).toList(),
        ),
      ],
    );
  }
}
