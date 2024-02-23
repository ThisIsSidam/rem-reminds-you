import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nagger/data/notification.dart';
import 'package:nagger/data/reminders_data.dart';
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
  bool firstTime = true;
  RemindersData db = RemindersData();
  var remindersList = <Reminder>[];
  var overdueList= <Reminder>[];
  var todayList = <Reminder>[];
  var tomorrowList = <Reminder>[];
  var laterList = <Reminder>[];

  @override
  void initState() {
    getList();

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
        db.deleteReminder(message['id']);
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
      getList();
      if (DateTime.now().second > 55)
      {
      print("refrshPage ${DateTime.now()}");
      }
    });
  }

  void getList() {
    // db.clearPendingRemovals();
    db.getReminders();
    remindersList = db.reminders.values.toList();

    overdueList = [];
    todayList = [];
    tomorrowList = [];
    laterList = [];

    remindersList.sort((a, b) => a.getDiffDuration().compareTo(b.getDiffDuration()));

    for (final reminder in remindersList)
    {
      Duration due = reminder.getDiffDuration();
      if (due.isNegative)
      {
        overdueList.add(reminder);
      }
      else if (due.inHours < 24) 
      {
        todayList.add(reminder);
      }
      else if (due.inHours < 48)
      {
        tomorrowList.add(reminder);
      }
      else
      {
        laterList.add(reminder);
      }
    };
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            HomePageListSection(
              name: "Overdue",
              remindersList: overdueList, 
              refreshHomePage: refreshPage
            ),
            HomePageListSection(
              name: "Today",
              remindersList: todayList, 
              refreshHomePage: refreshPage
            ),
            HomePageListSection(
              name: "Tomorrow",
              remindersList: tomorrowList, 
              refreshHomePage: refreshPage
            ),
            HomePageListSection(
              name: "Later",
              remindersList: laterList, 
              refreshHomePage: refreshPage
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
      ),
    );
  }
}