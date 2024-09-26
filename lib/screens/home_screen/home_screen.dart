import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/database.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/notification/notification.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/screens/archive_screen/archive_screen.dart';
import 'package:Rem/screens/home_screen/widgets/home_screen_lists.dart';
import 'package:Rem/screens/reminder_sheet/reminder_sheet.dart';
import 'package:Rem/screens/settings_screen/settings_screen.dart';
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
    
    refreshPage();
    _timer = Timer.periodic(Duration(seconds: 1), (_){
      refreshPage();
    });

    WidgetsBinding.instance.addObserver(this);

    NotificationController.startListeningNotificationEvents();

    super.initState();
    
    // Listening for reloading orderers
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
  }

  DateTime getDateTimeForNewReminder() {
    final addDuration = UserDB.getSetting(SettingOption.DueDateAddDuration);
    if (addDuration is Duration)
    {
      
      return DateTime.now().add(addDuration);
    }
    throw "[getDateTimeForNewReminder] Duration not received | $addDuration";
  }

  void refreshPage() {
    if (mounted) {
      setState(() {
        remindersMap = RemindersDatabaseController.getReminderLists();
        noOfReminders = RemindersDatabaseController.getNumberOfReminders();
      });
    }
  }

  void deleteAndRefresh(int id) {
    RemindersDatabaseController.moveToArchive(id);
    refreshPage();
  }

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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _getAppBar(),
      body: noOfReminders == 0 
      ? _getEmptyPage()
      : _getListedReminderPage(),
      floatingActionButton: _getFloatingActionButton(),
    );

  }

  AppBar _getAppBar() {
    return AppBar(
      surfaceTintColor: null,
      backgroundColor: Colors.transparent,
      title: Text(
        "Reminders",
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _getEmptyPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.alarm_off_outlined,
            size: 100,
          ),
          SizedBox(height: 20,),
          Text(
            "No Reminders",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget archiveIcon() {
    return IconButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ArchiveScreen()));
      },
      style: Theme.of(context).iconButtonTheme.style, 
      icon: Icon(Icons.archive)
    );
  }

  Widget settingsIcon() {
    return IconButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen.SettingsScreen()));
      },
      style: Theme.of(context).iconButtonTheme.style, 
      icon: Icon(Icons.settings)
    );
  }

  Widget _getListedReminderPage() {

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
                style: Theme.of(context).textTheme.titleMedium
              ),
              remindersList: remindersMap[overdueSectionTitle] ?? [],
              refreshPage: refreshPage,
            );
          case 1:
            return HomeScreenReminderListSection(
              label: Text(
                "Today", 
                style: Theme.of(context).textTheme.titleMedium
              ),
              remindersList: remindersMap[todaySectionTitle] ?? [],
              refreshPage: refreshPage,
            );
          case 2:
            return HomeScreenReminderListSection(
              label: Text(
                "Tomorrow", 
                style: Theme.of(context).textTheme.titleMedium
              ),
              remindersList: remindersMap[tomorrowSectionTitle] ?? [],
              refreshPage: refreshPage,
            );
          case 3:
            return HomeScreenReminderListSection(
              label: Text(
                "Later", 
                style: Theme.of(context).textTheme.titleMedium
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


  Widget _getFloatingActionButton() {
    return FloatingActionButton.large(
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
