import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/notification/notification.dart';
import 'package:nagger/database/database.dart';
import 'package:nagger/utils/homepage_list_section.dart';
import 'package:nagger/reminder_class/reminder.dart';
import 'package:nagger/utils/reminder_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  int noOfReminders = 0;
  Map<String, List<Reminder>> remindersMap = {};

  @override
  void initState() {
    remindersMap = RemindersDatabaseController.getReminderLists();

    _scheduleRefresh();
    NotificationController.initializeCallback(refreshPage);
    NotificationController.startListeningNotificationEvents();

    // Listening for reloading orderers
    final ReceivePort receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'main');
    receivePort.listen((dynamic message) {
      if (message is Map<String, dynamic>)
      {
        if (message["message"] == 'refreshHomePage')
        {
          print("REFRESHING PAGE-------");
          RemindersDatabaseController.deleteReminder(message['id']);
          refreshPage();
        }
        else 
        {
          print("Port message is not refreshHomePage");
        }
      }
    });

    super.initState();
  }

  // Returns DateTime with 0 seconds while 5 min in the future.
  DateTime getDateTimeForNewReminder() {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 5,
      0,
      0
    );
  }

  void _scheduleRefresh() {
    DateTime now = DateTime.now();
    Duration timeUntilNextRefresh = Duration(
      seconds: 10 - (now.second % 10),
      milliseconds: 1000 - now.millisecond
    );

    _timer = Timer(timeUntilNextRefresh, () {
      refreshPage();

      _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
        refreshPage();
      });
    });
  }

  void refreshPage() {
    setState(() {
      remindersMap = RemindersDatabaseController.getReminderLists();
      noOfReminders = RemindersDatabaseController.getNumberOfReminders();

      if (DateTime.now().second > 55)
      {
      print("refrshPage ${DateTime.now()}");
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nagger",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(onPressed: refreshPage, icon: const Icon(
            Icons.refresh,
            color: Colors.red,
            ))
        ],
      ),
      body: noOfReminders == 0
      ? getEmptyPage()
      : getListedReminderPage(),
      floatingActionButton: noOfReminders == 0
      ? null
      : getFloatingActionButton()
    );
  }

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
                  context: context, 
                  isScrollControlled: true,
                  builder: (BuildContext context) => ReminderSection(
                    thisReminder: Reminder(
                      dateAndTime: getDateTimeForNewReminder()
                    ), 
                    refreshHomePage: refreshPage
                  )
                );  
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Set a reminder",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getListedReminderPage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          HomePageListSection(
            name: overdueSectionTitle,
            remindersList: remindersMap[overdueSectionTitle] ?? [], 
            refreshHomePage: refreshPage
          ),
          HomePageListSection(
            name: todaySectionTitle,
            remindersList: remindersMap[todaySectionTitle] ?? [], 
            refreshHomePage: refreshPage
          ),
          HomePageListSection(
            name: tomorrowSectionTitle,
            remindersList: remindersMap[tomorrowSectionTitle] ?? [], 
            refreshHomePage: refreshPage
          ),
          HomePageListSection(
            name: laterSectionTitle,
            remindersList: remindersMap[laterSectionTitle] ?? [], 
            refreshHomePage: refreshPage
          ),
        ],
      ),
    );
  }

  Widget getFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context, 
          isScrollControlled: true,
          builder: (BuildContext context) => ReminderSection(
            thisReminder: Reminder(
              dateAndTime: getDateTimeForNewReminder()
            ), 
            refreshHomePage: refreshPage
          )
        );
      },
      child: const Icon(
        Icons.add,
      )
    );
  }
}