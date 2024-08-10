import 'package:Rem/pages/archive_page/archive_page.dart';
import 'package:Rem/pages/home_page/home_page.dart';
import 'package:Rem/pages/settings_page/settings_page.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class NavigationSection extends StatefulWidget {
  const NavigationSection({super.key});

  @override
  State<NavigationSection> createState() => _NavigationSectionState();
}

class _NavigationSectionState extends State<NavigationSection> {

  final List<GButton> _tabs = [
    GButton(icon: Icons.archive, text: "Archive"),
    GButton(icon: Icons.home, text: "Home"),
    GButton(icon: Icons.settings, text: "Settings"),
  ];

  final List<Widget> _pages = [
    ArchivePage(),
    HomePage(),
    SettingsPage(),
  ];

  int _selectedTab = 1; // Homepage by default.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DoubleBackToCloseApp(
        child: _pages[_selectedTab],
        snackBar: const SnackBar(
          content: Text("Tap back again to leave")
        ),
      ),
      bottomNavigationBar: GNav(
        tabs: _tabs,
        gap: 8,
        selectedIndex: _selectedTab,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        onTabChange: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
      ),
    );
  }
}