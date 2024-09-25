import 'package:Rem/screens/archive_screen/archive_screen.dart';
import 'package:Rem/screens/home_screen/home_screen.dart';
import 'package:Rem/screens/settings_screen/settings_screen.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class NavigationSection extends StatefulWidget {
  const NavigationSection({super.key});

  @override
  State<NavigationSection> createState() => _NavigationSectionState();
}

class _NavigationSectionState extends State<NavigationSection> {

  

  final List<Widget> _pages = [
    ArchiveScreen(),
    HomeScreen(),
    SettingsScreen.SettingsScreen(),
  ];

  int _selectedTab = 1; // Homepage by default.

  @override
  Widget build(BuildContext context) {

    final Color iconColor = Theme.of(context).textTheme.bodyLarge!.color!;
    final List<GButton> _tabs = [
      GButton(icon: Icons.archive, text: "Archive", iconColor: iconColor,
      iconActiveColor: iconColor,),
      GButton(icon: Icons.home, text: "Home", iconColor: iconColor,
      iconActiveColor: iconColor,),
      GButton(icon: Icons.settings, text: "Settings", iconColor: iconColor,
      iconActiveColor: iconColor,),
    ];

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
        padding: EdgeInsets.all(20),
        tabMargin: EdgeInsets.only(top: 8, bottom: 8),
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        rippleColor: Theme.of(context).colorScheme.onPrimary,
        activeColor: Theme.of(context).colorScheme.onPrimary,
        hoverColor: Theme.of(context).colorScheme.onPrimary,
        tabBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
        textStyle: Theme.of(context).textTheme.labelLarge,
        onTabChange: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
      ),
    );
  }
}