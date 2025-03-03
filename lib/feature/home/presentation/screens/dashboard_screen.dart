import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../shared/utils/logger/global_logger.dart';
import '../../../archives/presentation/screens/archive_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import 'home_screen.dart';

@immutable
class DashboardScreen extends HookConsumerWidget {
  const DashboardScreen({super.key});

  Widget _currentScreen(int index) {
    switch (index) {
      case 0:
        return const ArchiveScreen();
      case 1:
        return const HomeScreen();
      case 2:
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<int> currentScreen = useState<int>(1);
    gLogger.i('Built dashboard screen');
    return Scaffold(
      body: DoubleBackToCloseApp(
        snackBar: SnackBar(
          content: const Text('Tap back again to leave'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _currentScreen(currentScreen.value),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.archive),
            label: 'Archive',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: currentScreen.value,
        onTap: (int index) {
          currentScreen.value = index;
        },
      ),
    );
  }
}
