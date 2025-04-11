import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otomoto/core/models/navigation_item.dart';
import 'package:otomoto/core/widgets/navigation_drawer.dart';

class HomeScaffold extends ConsumerStatefulWidget {
  final List<String> pageTitles;
  final List<Widget> pageBodies;
  final List<NavigationItem> navigationItems;
  final int settingsIndex;
  final String userName;
  final String userRole;
  final VoidCallback onLogout;

  const HomeScaffold({
    super.key,
    required this.pageTitles,
    required this.pageBodies,
    required this.navigationItems,
    required this.settingsIndex,
    required this.userName,
    required this.userRole,
    required this.onLogout,
  });

  @override
  ConsumerState<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends ConsumerState<HomeScaffold> {
  int _selectedPageIndex = 0;

  void _onPageSelected(int index) {
    setState(() => _selectedPageIndex = index);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.userRole.toLowerCase() == 'admin';
    final appBarColor =
        isAdmin ? Colors.black54 : Theme.of(context).primaryColor;
    final titleTextColor = isAdmin ? Colors.white : Colors.black;

    return Scaffold(
      drawer: AppNavigationDrawer(
        onPageSelected: _onPageSelected,
        onLogout: widget.onLogout,
        userName: widget.userName,
        userRole: widget.userRole,
        navigationItems: widget.navigationItems,
        settingsIndex: widget.settingsIndex,
      ),
      appBar: AppBar(
        title: Text(
          widget.pageTitles[_selectedPageIndex],
          style: TextStyle(color: titleTextColor),
        ),
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(color: titleTextColor),
      ),
      body: IndexedStack(
        index: _selectedPageIndex,
        children: widget.pageBodies,
      ),
    );
  }
}
