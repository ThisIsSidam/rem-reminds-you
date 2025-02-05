import 'package:Rem/feature/archives/presentation/screens/archive_screen.dart';
import 'package:Rem/feature/home/presentation/screens/home_screen.dart';
import 'package:Rem/feature/settings/presentation/screens/settings_screen.dart';
import 'package:Rem/shared/utils/logger/global_logger.dart';
import 'package:Rem/shared/widgets/snack_bar/custom_snack_bar.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

@immutable
class NavigationLayer extends HookConsumerWidget {
  const NavigationLayer({super.key});

  Widget _currentScreen(int index) {
    switch (index) {
      case 0:
        return ArchiveScreen();
      case 1:
        return const HomeScreen();
      case 2:
        return SettingsScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<int> currentScreen = useState<int>(1);
    gLogger.i('Build navigation layer');
    return Scaffold(
      body: DoubleBackToCloseApp(
        child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: _currentScreen(currentScreen.value)),
        snackBar: buildCustomSnackBar(
          content: Align(
            alignment: Alignment.center,
            child: Text("Tap back again to leave",
                style: Theme.of(context).textTheme.bodyLarge),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.archive),
            label: "Archive",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
        unselectedFontSize: 12,
        selectedFontSize: 14,
        currentIndex: currentScreen.value,
        onTap: (index) {
          currentScreen.value = index;
        },
      ),
    );
  }
}
