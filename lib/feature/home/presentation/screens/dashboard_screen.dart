import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/notification_service/notification_service.dart';
import '../../../../main.dart';
import '../../../../shared/utils/logger/app_logger.dart';
import '../../../../shared/widgets/whats_new_dialog/whats_new_dialog.dart';
import '../../../agenda/presentation/screens/agenda_screen.dart';
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
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialScreen ?? 1;
    Future<void>.delayed(Duration.zero, () {
      _checkAndShowWhatsNewDialog();
      _handleInitialAction(ref);
    });
  }

  late final List<Widget> _screens = <Widget>[
    const AgendaScreen(key: ValueKey<String>('agenda-screen')),
    const ReminderScreen(key: ValueKey<String>('home-screen')),
    const SettingsScreen(key: ValueKey<String>('settings-screen')),
  ];

  /// Update the current screen being shown
  void _onItemSelected(int index) => setState(() => _selectedIndex = index);

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
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return const WhatsNewDialog();
        },
      );
    }
  }

  /// Handles actions received from notification taps
  Future<void> _handleInitialAction(WidgetRef ref) async {
    final ReceivedAction? initialAction = NotificationController.initialAction;

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
    await NotificationController.removeNotifications(initialAction.groupKey);
  }

  void _log(String msg) => AppLogger.i('[DashboardScreen] $msg');

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
