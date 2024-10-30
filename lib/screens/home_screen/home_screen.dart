import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:Rem/consts/consts.dart';
import 'package:Rem/main.dart';
import 'package:Rem/notification/notification.dart';
import 'package:Rem/provider/reminders_provider.dart';
import 'package:Rem/provider/settings_provider.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/screens/home_screen/widgets/home_screen_lists.dart';
import 'package:Rem/screens/reminder_sheet/reminder_sheet.dart';
import 'package:Rem/widgets/whats_new_dialog/whats_new_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  late Timer _timer; // ignore: unused_field
  Map<String, List<Reminder>> remindersMap = {};
  final ReceivePort receivePort = ReceivePort();
  SendPort? bgIsolate = IsolateNameServer.lookupPortByName(bg_isolate_name);

  @override
  void initState() {
    super.initState();
    remindersMap = ref.read(remindersProvider).categorizedReminders;

    WidgetsBinding.instance.addObserver(this);

    // Starts the listener for notification button click
    NotificationController.startListeningNotificationEvents();

    // Listening for an app side task request sent upon click on
    // notification button.
    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'main');
    receivePort.listen((dynamic message) {
      if (message is Map<String, dynamic>) {
        final id = message['id'];

        if (message["action"] == 'done') {
          ref.read(remindersProvider).markAsDone(id);
        } else {
          debugPrint("Port message is not refreshHomePage");
        }
      } else if (message is String) {
        if (message == "ping") {
          final notifPingPort =
              IsolateNameServer.lookupPortByName('NotificationIsolate');
          if (notifPingPort != null)
            notifPingPort.send("pong");
          else
            debugPrint("[homePageListener] notifPingPort is null");
        } else {
          debugPrint(
              "[homepageListener] Unknown string message received $message");
        }
      } else {
        debugPrint("[homepageListener] Unknown message received $message");
      }
    });

    // Show the what's new dialog
    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      WhatsNewDialog.checkAndShowWhatsNewDialog(navigatorKey.currentContext!);
    });
  }

  @override
  void dispose() {
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
              noRemindersPageText,
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
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return ReminderSheet(
                          thisReminder: Reminder(
                              dateAndTime: DateTime.now().add(ref
                                  .read(userSettingsProvider)
                                  .defaultLeadDuration)),
                        );
                      });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Set a reminder",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
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
        onPressed: () {
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) {
                return ReminderSheet(
                  thisReminder: Reminder(
                      dateAndTime: DateTime.now().add(
                          ref.read(userSettingsProvider).defaultLeadDuration)),
                );
              });
        },
        child: const Icon(
          Icons.add,
        ));
  }
}
