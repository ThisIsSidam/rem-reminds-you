import 'package:flutter/material.dart';

import '../../../settings/presentation/screens/settings_screen.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = <Widget>[
    const HomeScreen(key: ValueKey<String>('home-screen')),
    const SettingsScreen(key: ValueKey<String>('settings-screen')),
  ];

  void _onItemSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalMargin = screenWidth < 400 ? 16 : 36;
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        height: 50,
        iconSize: 16,
        margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 16),
        items: <BottomNavItem>[
          BottomNavItem(
            label: 'Home',
            icon: Icons.home,
            selectedIcon: Icons.home,
          ),
          BottomNavItem(
            label: 'Settings',
            icon: Icons.settings,
            selectedIcon: Icons.settings,
          ),
        ],
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}
