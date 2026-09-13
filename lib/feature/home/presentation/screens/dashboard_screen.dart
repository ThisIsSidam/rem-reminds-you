import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/extensions/context_ext.dart';
import '../../../../core/services/notification_service/notification_service.dart';
import '../../../../main.dart';
import '../../../../shared/utils/logger/app_logger.dart';
import '../../../../shared/widgets/whats_new_sheet/whats_new_sheet.dart';
import '../../../reminder/data/models/reminder.dart';
import '../../../reminder/presentation/screens/reminder_screen.dart';
import '../../../reminder_sheet/presentation/sheet/reminder_sheet.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../widgets/app_bottom_nav_bar.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({this.initialScreen, super.key});

  final int? initialScreen;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final ValueNotifier<int> _selectedIndexNotifier;

  @override
  void initState() {
    super.initState();
    _selectedIndexNotifier = ValueNotifier<int>(widget.initialScreen ?? 0);
    Future<void>.delayed(Duration.zero, () {
      _checkAndShowWhatsNewDialog();
      _handleInitialAction(ref);
    });
  }

  late final List<Widget> _screens = <Widget>[
    const ReminderScreen(key: ValueKey<String>('reminder-screen')),
    const SettingsScreen(key: ValueKey<String>('settings-screen')),
  ];

  /// Update the current screen being shown
  void _onItemSelected(int index) =>
      setState(() => _selectedIndexNotifier.value = index);

  /// Check if app version stored in SharedPrefs match with current
  /// version or not. If not, show the dialog and save the
  /// current version.
  Future<void> _checkAndShowWhatsNewDialog() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final int currentBuild = int.tryParse(packageInfo.buildNumber) ?? 1;
    final SharedPreferences prefs = getIt<SharedPreferences>();
    final int storedBuild = prefs.getInt('storedBuildNumber') ?? 1;
    if (currentBuild > storedBuild) {
      await prefs.setInt('storedBuildNumber', currentBuild);
      if (!mounted) return;
      await showWhatsNewSheet(context);
    }
  }

  /// Handles actions received from notification taps
  Future<void> _handleInitialAction(WidgetRef ref) async {
    final ReceivedAction? initialAction = NotificationService.initialAction;

    if (initialAction == null) return;
    if (initialAction.actionType != .Default) return;

    final Map<String, String?>? payload = initialAction.payload;
    if (payload == null) {
      return _log(
        'Received null payload through notification action '
        '| gKey : ${initialAction.groupKey}',
      );
    }

    // Don't use widget's context, since we navigate to different
    // screen in _handleRouting just before this method gets called.
    final BuildContext context = navigatorKey.currentContext!;
    final ReminderModel reminder = ReminderModel.fromJson(payload);

    if (context.mounted) {
      showReminderSheet(context, reminder: reminder);
    }
    await NotificationService.removeNotificationsByGroupKey(
      initialAction.groupKey,
    );
  }

  void _log(String msg) => AppLogger.i('[DashboardScreen] $msg');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: _selectedIndexNotifier,
            builder: (context, selectedIndex, _) {
              return IndexedStack(index: selectedIndex, children: _screens);
            },
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ValueListenableBuilder(
              valueListenable: _selectedIndexNotifier,
              builder: (context, selectedIndex, _) {
                final bool showFab = selectedIndex == 0;
                return Row(
                  children: [
                    Expanded(
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _buildNavBar(selectedIndex),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.horizontal,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: showFab
                          ? _buildFab(selectedIndex)
                          : const SizedBox(key: ValueKey('empty')),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  AppBottomNavBar _buildNavBar(int selectedIndex) {
    return AppBottomNavBar(
      height: 50,
      iconSize: 16,
      isFloating: true,
      items: <BottomNavItem>[
        BottomNavItem(
          label: 'Reminders',
          icon: Icons.checklist_rounded,
          selectedIcon: Icons.checklist_rounded,
        ),
        BottomNavItem(
          label: 'Settings',
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
        ),
      ],
      selectedIndex: selectedIndex,
      onItemSelected: _onItemSelected,
    );
  }

  Padding _buildFab(int selectedIndex) {
    return Padding(
      key: const ValueKey('fab'),
      padding: const EdgeInsets.only(left: 8),
      child: ElevatedButton(
        onPressed: () {
          if (selectedIndex == 0) {
            showReminderSheet(context);
          }
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.square(70),
          backgroundColor: context.colors.primaryContainer,
          foregroundColor: context.colors.onPrimaryContainer,
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
