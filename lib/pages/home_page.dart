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
      body: remindersList.isEmpty 
      ? Center(
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
      )
      : SingleChildScrollView(
        child: Column(
          children: [
            HomePageListSection(
              name: overdueSectionTitle,
              remindersList: overdueList, 
              refreshHomePage: refreshPage
            ),
            HomePageListSection(
              name: todaySectionTitle,
              remindersList: todayList, 
              refreshHomePage: refreshPage
            ),
            HomePageListSection(
              name: tomorrowSectionTitle,
              remindersList: tomorrowList, 
              refreshHomePage: refreshPage
            ),
            HomePageListSection(
              name: laterSectionTitle,
              remindersList: laterList, 
              refreshHomePage: refreshPage
            ),
          ],
        ),
      ),
      floatingActionButton: remindersList.isEmpty
      ? null
      : FloatingActionButton(
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