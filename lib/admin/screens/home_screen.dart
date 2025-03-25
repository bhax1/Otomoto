import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  bool _isLoading = true; // Track loading state

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
  void initState() {
    super.initState();
    _loadData();
  }

  // Simulate loading for the entire content of the pages
  Future<void> _loadData() async {
    try {
      // Assuming data loading functions for each page (you should replace these with real fetching logic)
      Future<void> dashboardData = loadDashboardData();
      Future<void> staffData = loadStaffData();
      Future<void> vehicleData = loadVehicleData();

      // Wait for all the data to be fetched
      await Future.wait([dashboardData, staffData, vehicleData]);

      setState(() {
        _isLoading =
            false; // Once everything is loaded, stop the loading indicator
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // In case of an error, stop loading
      });
      print("Error loading data: $e");
    }
  }

  // Simulate loading data functions for each page
  Future<void> loadDashboardData() async {
    // Replace this with your actual data fetching logic (e.g., from Firebase or an API)
    await Future.delayed(Duration(seconds: 2)); // Simulate delay
    print("Dashboard data loaded");
  }

  Future<void> loadStaffData() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate delay
    print("Staff data loaded");
  }

  Future<void> loadVehicleData() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate delay
    print("Vehicle data loaded");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(onPageSelected: _onPageSelected),
      appBar: AppBar(
        title: Text(pageTitles[_selectedPageIndex]),
      ),
      body: _isLoading
          ? Center(
              child: SpinKitFadingCircle(
                color: Theme.of(context).primaryColor,
                size: 50.0,
              ),
            )
          : IndexedStack(
              index: _selectedPageIndex,
              children: pageBodies,
            ),
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
