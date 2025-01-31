import 'dart:isolate';
import 'dart:ui';

import 'package:Rem/core/constants/const_strings.dart';
import 'package:Rem/core/services/notification_service/notification_service.dart';
import 'package:Rem/feature/home/presentation/providers/reminders_provider.dart';
import 'package:Rem/feature/home/presentation/widgets/home_screen_lists.dart';
import 'package:Rem/feature/reminder_screen/presentation/screens/reminder_screen.dart';
import 'package:Rem/main.dart';
import 'package:Rem/shared/widgets/whats_new_dialog/whats_new_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/reminder_model/reminder_model.dart';
import '../../../../shared/utils/logger/global_logger.dart';

enum HomeScreenSection {
  overdue('Overdue'),
  today('Today'),
  tomorrow('Tomorrow'),
  later('Later'),
  noRush('No Rush'),
  ;

  final String title;

  const HomeScreenSection(this.title);
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  Map<HomeScreenSection, List<ReminderModel>> remindersMap = {};
  final ReceivePort receivePort = ReceivePort();
  SendPort? bgIsolate = IsolateNameServer.lookupPortByName(bg_isolate_name);

  @override
  void initState() {
    super.initState();
    gLogger.i('HomeScreen initState');
    remindersMap = ref.read(
      remindersProvider.select((p) => p.categorizedReminders),
    );

    WidgetsBinding.instance.addObserver(this);

    // Starts the listener for notification button click
    NotificationController.startListeningNotificationEvents();

    // Listening for an app side task request sent upon click on
    // notification button.
    gLogger.i('Registering main port');
    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'main');
    receivePort.listen((dynamic message) {
      if (message is Map<String, dynamic>) {
        final id = message['id'];

        if (message["action"] == 'done') {
          gLogger.i('Received done action for $id');
          ref.read(remindersProvider).markAsDone(id);
        } else {
          gLogger.w('Port message is not "done", discarding');
        }
      } else if (message is String) {
        if (message == "ping") {
          gLogger.i('Received ping from NotificationIsolate');
          final notifPingPort =
              IsolateNameServer.lookupPortByName('NotificationIsolate');
          if (notifPingPort != null) {
            gLogger.i('Send back pong to notificationIsolate');
            notifPingPort.send("pong");
          } else {
            gLogger.w('notifPingPort is null');
          }
        } else {
          gLogger
              .w('[homepageListener] Unknown string message received $message');
        }
      } else {
        gLogger.w('[homepageListener] Unknown message received $message');
      }
    });

    // Show the what's new dialog
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      WhatsNewDialog.checkAndShowWhatsNewDialog(navigatorKey.currentContext!);
    });
  }

  @override
  void dispose() {
    gLogger.i('HomeScreen dispose');
    receivePort.close();
    IsolateNameServer.removePortNameMapping('main');

    if (mounted) {
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    remindersMap = ref.watch(
      remindersProvider.select((p) => p.categorizedReminders),
    );

    final isEmpty = ref.watch(remindersProvider).reminderCount == 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          isEmpty ? getEmptyPage() : getListedReminderPage()
        ],
      ),
      floatingActionButton: isEmpty ? null : getFloatingActionButton(),
    );
  }

  // The appbar for the home page.
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      surfaceTintColor: null,
      backgroundColor: Colors.transparent,
      title: Text(
        "Reminders",
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
          children: [
            Text(
              "You currently don't have any reminders!",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(
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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Set a reminder",
                      style: Theme.of(context).textTheme.bodyLarge),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  surfaceTintColor: Colors.transparent,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // The list of reminders widget used in scaffold body.
  Widget getListedReminderPage() {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          HomeScreenReminderListSection(
            label: _buildHomeSectionButton(
              label: HomeScreenSection.overdue.title,
              color: Theme.of(context).colorScheme.error,
            ),
            remindersList: remindersMap[HomeScreenSection.overdue] ?? [],
            hideIfEmpty: true,
          ),
          HomeScreenReminderListSection(
            label: _buildHomeSectionButton(
              onTap: () {
                _showReminderSheet();
              },
              label: HomeScreenSection.today.title,
              color: Theme.of(context).colorScheme.primary,
            ),
            remindersList: remindersMap[HomeScreenSection.today] ?? [],
          ),
          HomeScreenReminderListSection(
            label: _buildHomeSectionButton(
              onTap: () {
                _showReminderSheet(duration: Duration(days: 1));
              },
              label: HomeScreenSection.tomorrow.title,
              color: Theme.of(context).colorScheme.secondary,
            ),
            remindersList: remindersMap[HomeScreenSection.tomorrow] ?? [],
          ),
          HomeScreenReminderListSection(
            label: _buildHomeSectionButton(
              onTap: () {
                _showReminderSheet(duration: Duration(days: 7));
              },
              label: HomeScreenSection.later.title,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            remindersList: remindersMap[HomeScreenSection.later] ?? [],
          ),
          HomeScreenReminderListSection(
            label: _buildHomeSectionButton(
              onTap: () {
                _showReminderSheet(isNoRush: true);
              },
              label: HomeScreenSection.noRush.title,
              color: Theme.of(context).colorScheme.inverseSurface,
            ),
            remindersList: remindersMap[HomeScreenSection.noRush] ?? [],
          )
        ],
      ),
    );
  }

  // The floating Action button for adding new reminders.
  Widget getFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      onPressed: () {
        gLogger.i('Show new reminder sheet');
        _showReminderSheet();
      },
      child: const Icon(
        Icons.add,
      ),
    );
  }

  void _showReminderSheet(
      {ReminderModel? reminder, Duration? duration, bool isNoRush = false}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReminderScreen(
          reminder: reminder,
          customDuration: duration,
          isNoRush: isNoRush,
        ),
      ),
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
          padding: const EdgeInsets.all(4.0),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: color,
                ),
          ),
        ));
  }
}
