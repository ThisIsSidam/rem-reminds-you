import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/const_strings.dart';
import '../../../../core/data/models/reminder/reminder.dart';
import '../../../../core/enums/storage_enums.dart';
import '../../../../core/providers/global_providers.dart';
import '../../../../core/services/notification_service/notification_service.dart';
import '../../../../shared/utils/logger/global_logger.dart';
import '../../../../shared/utils/misc_methods.dart';
import '../../../../shared/widgets/whats_new_dialog/whats_new_dialog.dart';
import '../../../reminder_sheet/presentation/sheet_helper.dart';
import '../providers/reminders_provider.dart';
import '../widgets/home_screen_lists.dart';

enum HomeScreenSection {
  overdue('Overdue'),
  today('Today'),
  tomorrow('Tomorrow'),
  later('Later'),
  noRush('No Rush'),
  ;

  const HomeScreenSection(this.title);

  final String title;
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  Map<HomeScreenSection, List<ReminderModel>> remindersMap =
      <HomeScreenSection, List<ReminderModel>>{};
  final ReceivePort receivePort = ReceivePort();
  SendPort? bgIsolate = IsolateNameServer.lookupPortByName(bgIsolateName);

  @override
  void initState() {
    super.initState();
    gLogger.i('HomeScreen initState');

    WidgetsBinding.instance.addObserver(this);

    // Starts the listener for notification button click
    NotificationController.startListeningNotificationEvents();

    Future<void>.delayed(Duration.zero, _checkAndShowWhatsNewDialog);
    Future<void>.delayed(
      Duration.zero,
      () async {
        await NotificationController.handleInitialCallback(ref);
        return;
      },
    );
  }

  /// Check if app version stored in SharedPrefs match with current
  /// version or not. If not, show the dialog and save the
  /// current version.
  Future<void> _checkAndShowWhatsNewDialog() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String currentVersion = packageInfo.version;
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    final String storedVersion =
        prefs.getString(SharedKeys.appVersion.key) ?? '0.0.0';
    if (MiscMethods.compareVersions(storedVersion, currentVersion) < 0) {
      await prefs.setString(SharedKeys.appVersion.key, currentVersion);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return const WhatsNewDialog();
        },
      );
    }
  }

  @override
  void dispose() {
    gLogger.i('HomeScreen dispose');

    if (mounted) {
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    remindersMap = ref.watch(remindersNotifierProvider);
    final bool isEmpty = remindersMap.isEmpty;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: CustomScrollView(
        slivers: <Widget>[
          _buildAppBar(),
          if (isEmpty) getEmptyPage() else getListedReminderPage(),
        ],
      ),
      floatingActionButton: isEmpty ? null : getFloatingActionButton(),
    );
  }

  // The appbar for the home page.
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        'Reminders',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  // The empty page widget used in empty scaffold body.
  Widget getEmptyPage() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "You currently don't have any reminders!",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 75,
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  gLogger.i('Show new reminder sheet');
                  _showReminderSheet();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  surfaceTintColor: Colors.transparent,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Set a reminder',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // The list of reminders widget used in scaffold body.
  Widget getListedReminderPage() {
    return SliverList(
      delegate: SliverChildListDelegate(
        <Widget>[
          HomeScreenReminderListSection(
            label: _buildHomeSectionButton(
              label: HomeScreenSection.overdue.title,
              color: Theme.of(context).colorScheme.error,
            ),
            remindersList:
                remindersMap[HomeScreenSection.overdue] ?? <ReminderModel>[],
            hideIfEmpty: true,
          ),
          HomeScreenReminderListSection(
            label: _buildHomeSectionButton(
              onTap: _showReminderSheet,
              label: HomeScreenSection.today.title,
              color: Theme.of(context).colorScheme.primary,
            ),
            remindersList:
                remindersMap[HomeScreenSection.today] ?? <ReminderModel>[],
          ),
          HomeScreenReminderListSection(
            label: _buildHomeSectionButton(
              onTap: () {
                _showReminderSheet(duration: const Duration(days: 1));
              },
              label: HomeScreenSection.tomorrow.title,
              color: Theme.of(context).colorScheme.secondary,
            ),
            remindersList:
                remindersMap[HomeScreenSection.tomorrow] ?? <ReminderModel>[],
          ),
          HomeScreenReminderListSection(
            label: _buildHomeSectionButton(
              onTap: () {
                _showReminderSheet(duration: const Duration(days: 7));
              },
              label: HomeScreenSection.later.title,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            remindersList:
                remindersMap[HomeScreenSection.later] ?? <ReminderModel>[],
          ),
          HomeScreenReminderListSection(
            label: _buildHomeSectionButton(
              onTap: () {
                _showReminderSheet(isNoRush: true);
              },
              label: HomeScreenSection.noRush.title,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
            remindersList:
                remindersMap[HomeScreenSection.noRush] ?? <ReminderModel>[],
          ),
        ],
      ),
    );
  }

  // The floating Action button for adding new reminders.
  Widget getFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      onPressed: _showReminderSheet,
      child: const Icon(
        Icons.add,
      ),
    );
  }

  void _showReminderSheet({
    ReminderModel? reminder,
    Duration? duration,
    bool isNoRush = false,
  }) {
    SheetHelper().openReminderSheet(
      context,
      reminder: reminder,
      customDuration: duration,
      isNoRush: isNoRush,
    );
  }

  InkWell _buildHomeSectionButton({
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: color,
              ),
        ),
      ),
    );
  }
}
