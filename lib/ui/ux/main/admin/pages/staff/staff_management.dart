import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:otomoto/ui/ux/main/admin/pages/staff/components/staff_controller.dart';
import 'package:otomoto/ui/ux/main/admin/pages/staff/components/staff_data_source.dart';
import 'package:otomoto/ui/ux/main/admin/pages/staff/components/staff_providers.dart';
import 'package:otomoto/ui/ux/main/admin/pages/staff/staff_forms/add_staff.dart';
import 'package:otomoto/ui/ux/main/admin/pages/staff/staff_forms/delete_staff.dart';
import 'package:otomoto/ui/ux/main/admin/pages/staff/staff_forms/update_staff.dart';
import 'package:otomoto/ui/ux/main/admin/pages/staff/staff_forms/view_staff.dart';

class StaffManagement extends ConsumerWidget {
  const StaffManagement({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(staffControllerProvider);
    final controller = ref.read(staffControllerProvider.notifier);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(context, controller, state, ref),
            const SizedBox(height: 10),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: SpinKitThreeBounce(
                      color: Colors.blueGrey,
                    ))
                  : _buildDataTable(context, state, controller, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    StaffController controller,
    StaffState state,
    WidgetRef ref,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search...',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (value) => controller.filterStaff(value),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 200,
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Staff ID',
              prefixIcon: const Icon(Icons.confirmation_number_sharp),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (value) => controller.filterByStaffId(value),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () => _addStaff(context, ref),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('+ Add', style: TextStyle(color: Colors.white)),
        ),
        const Spacer(),
        if (state.externalUpdatesAvailable)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Badge(
              smallSize: 8,
              backgroundColor: Colors.red,
              child: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => controller.handleRefresh(),
              ),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.handleRefresh(),
          ),
      ],
    );
  }

  Widget _buildDataTable(
    BuildContext context,
    StaffState state,
    StaffController controller,
    WidgetRef ref,
  ) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: constraints.maxWidth,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTableTheme(
                data: DataTableThemeData(
                  headingRowColor: WidgetStateProperty.all(Colors.amber),
                  headingTextStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  dataRowColor:
                      WidgetStateProperty.resolveWith<Color?>((states) {
                    return states.contains(WidgetState.selected)
                        ? Colors.grey[300]
                        : null;
                  }),
                  dataTextStyle: const TextStyle(color: Colors.black87),
                  dividerThickness: 1.5,
                ),
                child: PaginatedDataTable(
                  columns: const [
                    DataColumn(label: Text('Staff ID')),
                    DataColumn(label: Text('First Name')),
                    DataColumn(label: Text('Last Name')),
                    DataColumn(label: Text('Job Position')),
                    DataColumn(label: Text('Contact Number')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  source: StaffDataSource(
                    staff: state.filteredStaff,
                    onView: (index) => _viewStaff(context, index, state),
                    onUpdate: (index) =>
                        _updateStaff(context, index, state, ref),
                    onDelete: (index) =>
                        _deleteStaff(context, index, state, ref),
                  ),
                  rowsPerPage: StaffState.rowsPerPage,
                  onPageChanged: (pageIndex) =>
                      controller.fetchStaff(page: pageIndex),
                  showFirstLastButtons: true,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addStaff(BuildContext context, WidgetRef ref) async {
    final result = await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const SizedBox(width: 500, child: AddStaffForm()),
      ),
    );
    if (result == true) {
      ref.read(staffControllerProvider.notifier).markLocalChange();
      ref.read(staffControllerProvider.notifier).fetchStaff();
    }
  }

  void _viewStaff(BuildContext context, int index, StaffState state) {
    showDialog(
      context: context,
      builder: (context) => ViewStaffForm(
        staffId: state.filteredStaff[index].id,
      ),
    );
  }

  Future<void> _updateStaff(
    BuildContext context,
    int index,
    StaffState state,
    WidgetRef ref,
  ) async {
    final result = await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 500,
          child: UpdateStaffForm(
            staffId: state.filteredStaff[index].id,
          ),
        ),
      ),
    );

    if (result == true) {
      ref.read(staffControllerProvider.notifier).markLocalChange();
      ref.read(staffControllerProvider.notifier).fetchStaff();
    }
  }

  Future<void> _deleteStaff(
    BuildContext context,
    int index,
    StaffState state,
    WidgetRef ref,
  ) async {
    final result = await showDialog(
      context: context,
      builder: (context) => DeleteStaffDialog(
        staffId: state.filteredStaff[index].id,
        staffName:
            "${state.filteredStaff[index].firstname} ${state.filteredStaff[index].lastname}",
      ),
    );
    if (result == true) {
      ref.read(staffControllerProvider.notifier).markLocalChange();
      ref.read(staffControllerProvider.notifier).fetchStaff();
    }
  }
}
