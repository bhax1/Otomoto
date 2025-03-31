import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:otomoto/admin/pages/dashboard/dashboard.dart';
import 'package:otomoto/admin/pages/staff/staff_management.dart';
import 'package:otomoto/admin/pages/maintenance/maintenance_management.dart';
import 'package:otomoto/admin/pages/vehicle/vehicle_management.dart';
import 'package:otomoto/admin/screens/admin_login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedPageIndex = 0;
  bool _isLoading = true;

  final List<String> pageTitles = [
    'Dashboard',
    'Staff Management',
    'Vehicle List',
    'Maintenance',
    'Profile Settings'
  ];

  final List<Widget> pageBodies = [
    const DashboardBody(),
    const StaffManagement(),
    const VehicleManagement(),
    const VehicleMaintenance(),
    const Center(child: Text('Profile Settings Page')),
  ];

  void _onPageSelected(int index) {
    setState(() {
      _selectedPageIndex = index;
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await Future.wait([
        loadDashboardData(),
        loadStaffData(),
        loadVehicleData(),
      ]);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> loadDashboardData() async => await Future.delayed(const Duration(seconds: 2));
  Future<void> loadStaffData() async => await Future.delayed(const Duration(seconds: 2));
  Future<void> loadVehicleData() async => await Future.delayed(const Duration(seconds: 2));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _isLoading ? null : NavigationDrawer(onPageSelected: _onPageSelected),
      appBar: AppBar(
        title: Text(pageTitles[_selectedPageIndex], style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? Center(child: SpinKitFadingCircle(color: Theme.of(context).primaryColor, size: 50.0))
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: pageBodies[_selectedPageIndex],
            ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  final Function(int) onPageSelected;
  const NavigationDrawer({super.key, required this.onPageSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // User Header with Avatar
          UserAccountsDrawerHeader(
            accountName: const Text("Admin User", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text("admin@example.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage('assets/avatar/admin_avatar.png'),
            ),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              children: [
                _buildDrawerItem(Icons.dashboard, 'Dashboard', 0),
                _buildDrawerItem(Icons.people, 'Staff Management', 1),
                ExpansionTile(
                  leading: const Icon(Icons.directions_car),
                  title: const Text('Vehicle Management'),
                  children: [
                    _buildDrawerItem(Icons.list, 'Vehicle List', 2),
                    _buildDrawerItem(Icons.build, 'Maintenance', 3),
                  ],
                ),
              ],
            ),
          ),

          // Spacer pushes items to bottom
          const Divider(),

          // Profile & Logout placed at the bottom
          _buildDrawerItem(Icons.settings, 'Profile Settings', 4),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context),
          ),
          const SizedBox(height: 20), // Space from bottom
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => onPageSelected(index),
    );
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => const AdminLogin(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
