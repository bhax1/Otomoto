import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otomoto/core/models/navigation_item.dart';
import 'package:otomoto/core/widgets/home_scaffold.dart';
import 'package:otomoto/auth/services/session_manager.dart';
import 'package:otomoto/auth/providers/auth_service_provider.dart';
import 'package:otomoto/ui/login/admin_login.dart';
import 'package:otomoto/core/models/user_model.dart';
import 'package:otomoto/ui/main/admin/pages/dashboard/dashboard.dart';
import 'package:otomoto/ui/main/admin/pages/staff/staff_management.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionManager = SessionManager();

    return FutureBuilder<UserModel?>(
      future: sessionManager.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No user data available'));
        } else {
          final user = snapshot.data!;

          return HomeScaffold(
            userName: user.name,
            userRole: 'Admin',
            onLogout: () async {
              await ref.read(authServiceProvider).logOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminLogin()),
                );
              }
            },
            pageTitles: const [
              'Dashboard',
              'Staff Management',
              'Vehicle List',
              'Maintenance',
              'Profile Settings',
            ],
            pageBodies: const [
              DashboardBody(),
              StaffManagement(),
              Center(child: Text('Vehicle List Page')),
              Center(child: Text('Maintenance')),
              Center(child: Text('Profile Settings Page')),
            ],
            navigationItems: const [
              NavigationItem(
                  icon: Icons.dashboard, title: 'Dashboard', index: 0),
              NavigationItem(
                  icon: Icons.people, title: 'Staff Management', index: 1),
              NavigationItem(
                  icon: Icons.directions_car, title: 'Vehicle List', index: 2),
              NavigationItem(icon: Icons.build, title: 'Maintenance', index: 3),
            ],
            settingsIndex: 4,
          );
        }
      },
    );
  }
}
