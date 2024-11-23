import 'dart:isolate';
import 'dart:ui';

import 'package:Rem/consts/consts.dart';
import 'package:Rem/main.dart';
import 'package:Rem/notification/notification.dart';
import 'package:Rem/provider/reminders_provider.dart';
import 'package:Rem/screens/home_screen/widgets/home_screen_lists.dart';
import 'package:Rem/screens/reminder_sheet/reminder_sheet.dart';
import 'package:Rem/widgets/whats_new_dialog/whats_new_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modals/reminder_modal/reminder_modal.dart';
import '../../utils/logger/global_logger.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  Map<String, List<ReminderModal>> remindersMap = {};
  final ReceivePort receivePort = ReceivePort();
  SendPort? bgIsolate = IsolateNameServer.lookupPortByName(bg_isolate_name);

  @override
  void initState() {
    super.initState();
    gLogger.i('HomeScreen initState');
    remindersMap =
        ref.read(remindersProvider.select((p) => p.categorizedReminders));

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
    remindersMap = ref.watch(remindersProvider).categorizedReminders;

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
            label: Text("Overdue",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.red)),
            remindersList: remindersMap[overdueSectionTitle] ?? [],
          ),
          HomeScreenReminderListSection(
            label: Text("Today",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Theme.of(context).colorScheme.primary)),
            remindersList: remindersMap[todaySectionTitle] ?? [],
          ),
          HomeScreenReminderListSection(
            label: Text("Tomorrow",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.green)),
            remindersList: remindersMap[tomorrowSectionTitle] ?? [],
          ),
          HomeScreenReminderListSection(
            label: Text("Later",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.yellow)),
            remindersList: remindersMap[laterSectionTitle] ?? [],
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
        onPressed: () {
          gLogger.i('Show new reminder sheet');
          _showReminderSheet();
        },
        child: const Icon(
          Icons.add,
        ));
  }

  void _showReminderSheet({ReminderModal? reminder}) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return ReminderSheet(
            reminder: reminder,
          );
        });
  }
}
