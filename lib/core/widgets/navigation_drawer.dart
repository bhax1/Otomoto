import 'package:flutter/material.dart';
import 'package:otomoto/core/models/navigation_item.dart';

class AppNavigationDrawer extends StatelessWidget {
  final List<NavigationItem> navigationItems;
  final int settingsIndex;
  final ValueChanged<int> onPageSelected;
  final VoidCallback onLogout;
  final String userName;
  final String userRole;

  const AppNavigationDrawer({
    super.key,
    required this.navigationItems,
    required this.settingsIndex,
    required this.onPageSelected,
    required this.onLogout,
    required this.userName,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildMainNavigation(context)),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isAdmin = userRole.toLowerCase() == 'admin';
    final backgroundColor =
        isAdmin ? Colors.black : Theme.of(context).primaryColor;
    final textColor = isAdmin ? Colors.white : Colors.black;

    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundColor, backgroundColor.withOpacity(0.8)],
        ),
      ),
      accountName: Text(userName,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      accountEmail: Text(userRole, style: TextStyle(color: textColor)),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Text(
          userName.isNotEmpty ? userName[0] : '',
          style: TextStyle(
              color: backgroundColor,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildMainNavigation(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: navigationItems.map((item) {
        return _buildNavigationTile(context,
            icon: item.icon, title: item.title, index: item.index);
      }).toList(),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        _buildNavigationTile(
          context,
          icon: Icons.settings,
          title: 'Profile Settings',
          index: settingsIndex,
        ),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: onLogout,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildNavigationTile(BuildContext context,
      {required IconData icon, required String title, required int index}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => onPageSelected(index),
    );
  }
}
