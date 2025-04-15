import 'package:flutter/material.dart';

class StaffDataSource extends DataTableSource {
  final List<Map<String, dynamic>> staff;
  final Function(int) onView;
  final Function(int) onUpdate;
  final Function(int) onDelete;

  StaffDataSource(this.staff, this.onView, this.onUpdate, this.onDelete);

  @override
  DataRow? getRow(int index) {
    if (index >= staff.length) return null;
    final staffMember = staff[index];

    String status = staffMember['status'];
    status = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1).toLowerCase()
        : '';

    return DataRow(cells: [
      DataCell(Text(staffMember['id'])),
      DataCell(Text(staffMember['firstname'])),
      DataCell(Text(staffMember['lastname'])),
      DataCell(Text(staffMember['roles'])),
      DataCell(Text(staffMember['contact'])),
      DataCell(Text(staffMember['email'])),
      DataCell(
        Text(
          status,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: staffMember['status'] == 'active'
                ? Colors.green
                : staffMember['status'] == 'inactive'
                    ? Colors.red
                    : Colors.blueGrey,
          ),
        ),
      ),
      DataCell(
        Row(
          children: [
            _buildIconButton(
                Icons.visibility, Colors.orange, () => onView(index)),
            if (staffMember['status'] != "Removed") ...[
              _buildIconButton(Icons.edit, Colors.blue, () => onUpdate(index)),
              _buildIconButton(Icons.delete, Colors.red, () => onDelete(index)),
            ]
          ],
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => staff.length;

  @override
  int get selectedRowCount => 0;

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onPressed,
    );
  }
}
