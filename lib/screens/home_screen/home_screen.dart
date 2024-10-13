import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/database.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/main.dart';
import 'package:Rem/notification/notification.dart';
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

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  int noOfReminders = 0;
  late Timer _timer; // ignore: unused_field  
  Map<String, List<Reminder>> remindersMap = {};
  final ReceivePort receivePort = ReceivePort();
  SendPort? bgIsolate = IsolateNameServer.lookupPortByName(bg_isolate_name);

  @override
  void initState() {
    super.initState();
    
    // Page refreshes every second
    // I think I shouldn't be doing this. 
    //TODO: Check if I need to reload every second
    refreshPage();
    _timer = Timer.periodic(Duration(seconds: 1), (_){
      refreshPage();
    });

    WidgetsBinding.instance.addObserver(this);

    // Starts the listener for notification button click
    NotificationController.startListeningNotificationEvents();

    // Listening for an app side task request sent upon click on 
    // notification button.
    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'main');
    receivePort.listen((dynamic message) {
      if (message is Map<String, dynamic>)
      {
        final id = message['id'];

        if (message["action"] == 'done')
        {
          RemindersDatabaseController.markAsDone(id);
          refreshPage();
        }
        else 
        {
          debugPrint("Port message is not refreshHomePage");
        }
      }
      else if (message is String)
      {
        if (message == "ping")
        {
          final notifPingPort = IsolateNameServer.lookupPortByName('NotificationIsolate');
          if (notifPingPort != null) notifPingPort.send("pong");
          else debugPrint("[homePageListener] notifPingPort is null");
        }
        else {
          debugPrint("[homepageListener] Unknown string message received $message");
        }
      }
      else 
      {
        debugPrint("[homepageListener] Unknown message received $message");
      }
    });

    // Show the what's new dialog
    WidgetsBinding.instance.addPersistentFrameCallback(
      (_) {
        WhatsNewDialog.checkAndShowWhatsNewDialog(navigatorKey.currentContext!);
      }
    );
  }

  // Get the dateTime for the new reminder
  DateTime getDateTimeForNewReminder() {
    final addDuration = UserDB.getSetting(SettingOption.DueDateAddDuration);
    if (addDuration is Duration)
    {
      
      return DateTime.now().add(addDuration);
    }
    throw "[getDateTimeForNewReminder] Duration not received | $addDuration";
  }

  // Refreshes the page
  // Update the list of reminders
  void refreshPage() {
    if (mounted) {
      setState(() {
        remindersMap = RemindersDatabaseController.getReminderLists();
        noOfReminders = RemindersDatabaseController.getNumberOfReminders();
      });
    }
  }

  // Reloading when the user comes back after switching apps
  // or something. 
  // I don't know if I still need it. Will check later.
  //TODO: Check if I still need it
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      dispose();
    }
    if (state == AppLifecycleState.resumed) {
      refreshPage();
    }
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

    // Empty scaffold when no reminders.
    if (noOfReminders == 0)
    {
      return Scaffold(
        appBar: getAppBar(),
        body: getEmptyPage()
      );
    }

    // Proper scaffold when reminders are present
    return Scaffold(
      appBar: getAppBar(),
      body: getListedReminderPage(),
      floatingActionButton: getFloatingActionButton()
    );
  }

  // The appbar for the home page.
  AppBar getAppBar() {
    return AppBar(
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            noRemindersPageText,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 20,),
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
                      thisReminder: Reminder(dateAndTime: getDateTimeForNewReminder()), 
                      refreshHomePage: refreshPage
                    );
                  }
                ); 
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Set a reminder",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor)
              )
            ),
          )
        ],
      ),
    );
  }

  // The list of reminders widget used in scaffold body.
  Widget getListedReminderPage() {

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      itemCount: 4,
      // separatorBuilder: (BuildContext context, int index) => SizedBox(height: 8.0),
      itemBuilder: (BuildContext context, int index) {
        switch (index) {
          case 0:
            return HomeScreenReminderListSection(
              label: Text(
                "Overdue", 
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.red)
              ),
              remindersList: remindersMap[overdueSectionTitle] ?? [],
              refreshPage: refreshPage,
            );
          case 1:
            return HomeScreenReminderListSection(
              label: Text(
                "Today", 
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).primaryColor)
              ),
              remindersList: remindersMap[todaySectionTitle] ?? [],
              refreshPage: refreshPage,
            );
          case 2:
            return HomeScreenReminderListSection(
              label: Text(
                "Tomorrow", 
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.green)
              ),
              remindersList: remindersMap[tomorrowSectionTitle] ?? [],
              refreshPage: refreshPage,
            );
          case 3:
            return HomeScreenReminderListSection(
              label: Text(
                "Later", 
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.yellow)
              ),
              remindersList: remindersMap[laterSectionTitle] ?? [],
              refreshPage: refreshPage,
            );
          default:
            return SizedBox.shrink();
        }
      },
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
              thisReminder: Reminder(dateAndTime: getDateTimeForNewReminder()), 
              refreshHomePage: refreshPage
            );
          }
        ); 
      },
      child: const Icon(
        Icons.add,
      )
    );
  }
}
