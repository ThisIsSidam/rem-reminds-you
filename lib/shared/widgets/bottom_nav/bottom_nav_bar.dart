import 'package:Rem/feature/archives/presentation/screens/archive_screen.dart';
import 'package:Rem/feature/home/presentation/screens/home_screen.dart';
import 'package:Rem/feature/settings/presentation/screens/settings_screen.dart';
import 'package:Rem/shared/widgets/snack_bar/custom_snack_bar.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../utils/logger/global_logger.dart';

class NavigationLayer extends StatefulWidget {
  const NavigationLayer({super.key});

  @override
  State<NavigationLayer> createState() => _NavigationLayerState();
}

class _NavigationLayerState extends State<NavigationLayer> {
  final List<GButton> _tabs = [
    GButton(icon: Icons.archive, text: "Archive"),
    GButton(icon: Icons.home, text: "Home"),
    GButton(icon: Icons.settings, text: "Settings"),
  ];

  final List<Widget> _pages = [
    ArchiveScreen(),
    HomeScreen(),
    SettingsScreen(),
  ];

  int _selectedTab = 1; // Homepage by default.

  @override
  Widget build(BuildContext context) {
    gLogger.i('Build navigation layer');
    return Scaffold(
      body: DoubleBackToCloseApp(
        child: _pages[_selectedTab],
        snackBar: buildCustomSnackBar(
          content: Align(
            alignment: Alignment.center,
            child: Text("Tap back again to leave",
                style: Theme.of(context).textTheme.bodyLarge),
          ),
        ),
      ),
      bottomNavigationBar: GNav(
        tabs: _tabs,
        gap: 8,
        selectedIndex: _selectedTab,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        onTabChange: (index) {
          gLogger.i('Navigating to ${_tabs[index].text}');
          setState(() {
            _selectedTab = index;
          });
        },
      ),
    );
  }
}
