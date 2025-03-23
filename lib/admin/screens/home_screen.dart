import 'package:flutter/material.dart';
import 'package:otomoto/admin/pages/dashboard.dart';
import 'package:otomoto/admin/pages/staff_management.dart';
import 'package:otomoto/admin/pages/vehicle_management.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedPageIndex = 0;

  final List<String> pageTitles = [
    'Dashboard',
    'Staff Management',
    'Vehicle List',
    'Maintenance',
    'Profile Settings'
  ];

  final List<Widget> pageBodies = [
    DashboardBody(),
    StaffManagement(),
    VehicleManagement(),
    Center(child: Text('Maintenance')),
    Center(child: Text('Profile Settings Page')),
  ];

  void _onPageSelected(int index) {
    setState(() {
      _selectedPageIndex = index;
      Navigator.pop(context); // Close the drawer
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(onPageSelected: _onPageSelected),
      appBar: AppBar(
        title: Text(pageTitles[_selectedPageIndex]),
      ),
      body: pageBodies[_selectedPageIndex],
    );
  }
}

class NavigationDrawer extends StatefulWidget {
  final Function(int) onPageSelected;
  const NavigationDrawer({super.key, required this.onPageSelected});

  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor, // Uses the theme color
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          ListTile(
            title: Text('Dashboard'),
            onTap: () => widget.onPageSelected(0),
          ),
          ListTile(
            title: Text('Staff Management'),
            onTap: () => widget.onPageSelected(1),
          ),
          ExpansionTile(
            title: Text('Vehicle Management'),
            children: [
              ListTile(
                title: Text('Vehicle List'),
                onTap: () => widget.onPageSelected(2),
              ),
              ListTile(
                title: Text('Maintenance'),
                onTap: () => widget.onPageSelected(3),
              ),
            ],
          ),
          ListTile(
            title: Text('Profile Settings'),
            onTap: () => widget.onPageSelected(4),
          ),
          ListTile(
            title: Text('Logout Account', style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
