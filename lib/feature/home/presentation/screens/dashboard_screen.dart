import 'package:flutter/material.dart';

import '../../../agenda/presentation/screens/agenda_screen.dart';
import '../../../reminder/presentation/screens/reminder_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../widgets/app_bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 1;

  late final List<Widget> _screens = <Widget>[
    const AgendaScreen(key: ValueKey<String>('agenda-screen')),
    const ReminderScreen(key: ValueKey<String>('home-screen')),
    const SettingsScreen(key: ValueKey<String>('settings-screen')),
  ];

  /// Update the current screen being shown
  void _onItemSelected(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalMargin = screenWidth < 400 ? 16 : 36;
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: AppBottomNavBar(
        height: 50,
        iconSize: 16,
        margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 16),
        items: <BottomNavItem>[
          BottomNavItem(
            label: 'Agenda',
            icon: Icons.view_agenda_outlined,
            selectedIcon: Icons.view_agenda,
          ),
          BottomNavItem(
            label: 'Home',
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
          ),
          BottomNavItem(
            label: 'Settings',
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
          ),
        ],
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
    );
  }
}
