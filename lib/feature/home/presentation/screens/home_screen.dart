import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/data/models/reminder/reminder.dart';
import '../../../../core/extensions/context_ext.dart';
import '../../../../core/services/notification_service/notification_service.dart';
import '../../../../main.dart';
import '../../../../shared/utils/logger/app_logger.dart';
import '../../../../shared/widgets/whats_new_dialog/whats_new_dialog.dart';
import '../../../reminder_sheet/presentation/sheet_helper.dart';
import '../providers/no_rush_provider.dart';
import '../providers/reminders_provider.dart';
import '../widgets/home_screen_lists.dart';

enum HomeScreenSection {
  overdue,
  today,
  tomorrow,
  later,
  noRush;

  bool get isOverdue => this == overdue;

  String localizedTitle(BuildContext context) {
    return switch (this) {
      HomeScreenSection.overdue => context.local.homeSectionOverdue,
      HomeScreenSection.today => context.local.homeSectionToday,
      HomeScreenSection.tomorrow => context.local.homeSectionTomorrow,
      HomeScreenSection.later => context.local.homeSectionLater,
      HomeScreenSection.noRush => context.local.homeSectionNoRush,
    };
  }

  Color getColor(BuildContext context) {
    final ColorScheme colors = context.colors;
    return switch (this) {
      overdue => colors.error,
      today => colors.primary,
      tomorrow => colors.secondary,
      later => colors.inversePrimary,
      noRush => colors.inverseSurface
    };
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    AppLogger.i('HomeScreen initState');

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

  @override
  void dispose() {
    AppLogger.i('HomeScreen dispose');

    if (mounted) {
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty =
        ref.watch(remindersNotifierProvider.notifier).isEmpty() &&
            ref.watch(noRushRemindersNotifierProvider.notifier).isEmpty();

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
        context.local.homeTitle,
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
              context.local.emptyReminders,
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
                  AppLogger.i('Show new reminder sheet');
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
                    context.local.setReminder,
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
          const ListedReminderSection(
            key: ValueKey<HomeScreenSection>(HomeScreenSection.overdue),
            section: HomeScreenSection.overdue,
            hideIfEmpty: true,
          ),
          ListedReminderSection(
            section: HomeScreenSection.today,
            onTapTitle: _showReminderSheet,
          ),
          ListedReminderSection(
            section: HomeScreenSection.tomorrow,
            onTapTitle: () {
              _showReminderSheet(duration: const Duration(days: 1));
            },
          ),
          ListedReminderSection(
            section: HomeScreenSection.later,
            onTapTitle: () {
              _showReminderSheet(duration: const Duration(days: 7));
            },
          ),
          const ListedNoRushSection(),
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
}
