import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otomoto/core/widgets/home_scaffold.dart';
import 'package:otomoto/auth/providers/auth_service_provider.dart';
import 'package:otomoto/auth/services/session_manager.dart';
import 'package:otomoto/ui/login/admin_login.dart';
import 'package:otomoto/core/models/user_model.dart';
import 'package:otomoto/core/models/navigation_item.dart';

class StaffHomeScreen extends ConsumerWidget {
  const StaffHomeScreen({super.key});

  String getUserRoles(List<int> roles) {
    final roleMap = {
      1: 'Admin',
      2: 'Booking Manager',
      3: 'Booking Agent',
      4: 'Car Manager',
    };

    final roleNames = roles
        .where((id) => roleMap.containsKey(id))
        .map((id) => roleMap[id])
        .toList();

    return roleNames.isNotEmpty ? roleNames.join(' | ') : 'Unknown Role';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<UserModel?>(
      future: SessionManager().getUser(),
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
            userRole: getUserRoles(user.roles),
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
              'Booking Management',
              'Profile Settings',
            ],
            pageBodies: const [
              Center(child: Text('Dashboard')),
              Center(child: Text('Booking Management')),
              Center(child: Text('Profile Settings')),
            ],
            navigationItems: [
              const NavigationItem(
                icon: Icons.dashboard,
                title: 'Dashboard',
                index: 0,
              ),
              if (user.roles.contains(2) || user.roles.contains(3))
                const NavigationItem(
                  icon: Icons.book_online,
                  title: 'Booking Management',
                  index: 1,
                ),
              if (user.roles.contains(4))
                const NavigationItem(
                  icon: Icons.inventory_rounded,
                  title: 'Car Inventory',
                  index: 1,
                ),
            ],
            settingsIndex: 2,
          );
        }
      },
    );
  }
}
