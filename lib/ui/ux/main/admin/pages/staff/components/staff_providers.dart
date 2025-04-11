import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otomoto/ui/ux/main/admin/pages/staff/components/staff_controller.dart';
import 'package:otomoto/ui/ux/main/admin/pages/staff/components/staff_models.dart';

final staffControllerProvider =
    StateNotifierProvider<StaffController, StaffState>((ref) {
  return StaffController();
});

class StaffState {
  final List<StaffMember> staffList;
  final List<StaffMember> filteredStaff;
  final bool isLoading;
  final bool externalUpdatesAvailable;
  final int currentPage;
  final String? error;
  final String? searchQuery; // Add this
  final String? staffIdQuery; // Add this

  static const int rowsPerPage = 10;

  StaffState({
    this.staffList = const [],
    this.filteredStaff = const [],
    this.isLoading = false,
    this.externalUpdatesAvailable = false,
    this.currentPage = 0,
    this.error,
    this.searchQuery,
    this.staffIdQuery,
  });

  // Update copyWith to include new fields
  StaffState copyWith({
    List<StaffMember>? staffList,
    List<StaffMember>? filteredStaff,
    bool? isLoading,
    bool? externalUpdatesAvailable,
    int? currentPage,
    String? error,
    String? searchQuery,
    String? staffIdQuery,
  }) {
    return StaffState(
      staffList: staffList ?? this.staffList,
      filteredStaff: filteredStaff ?? this.filteredStaff,
      isLoading: isLoading ?? this.isLoading,
      externalUpdatesAvailable:
          externalUpdatesAvailable ?? this.externalUpdatesAvailable,
      currentPage: currentPage ?? this.currentPage,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      staffIdQuery: staffIdQuery ?? this.staffIdQuery,
    );
  }
}
