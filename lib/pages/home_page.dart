import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nagger/consts/const_colors.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/notification/notification.dart';
import 'package:nagger/database/database.dart';
import 'package:nagger/utils/home_pg_utils/homepage_list_section.dart';
import 'package:nagger/reminder_class/reminder.dart';
import 'package:nagger/pages/reminder_page.dart';

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
    NotificationController.startListeningNotificationEvents();

    // Listening for reloading orderers
    final ReceivePort receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(receivePort.sendPort, 'main');
    receivePort.listen((dynamic message) {
      if (message is Map<String, dynamic>)
      {
        if (message["message"] == 'refreshHomePage')
        {
          debugPrint("REFRESHING PAGE-------");
          RemindersDatabaseController.deleteReminder(message['id']);
          refreshPage();
        }
        else 
        {
          debugPrint("Port message is not refreshHomePage");
        }
      }
    });

    super.initState();
  }

  // Returns DateTime with 0 seconds while 5 min in the future.
  DateTime getDateTimeForNewReminder() {
    final now = DateTime.now();
    final result = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 5,
      0,
      0
    );

    return result;
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
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (noOfReminders == 0)
    {
      return Scaffold(
        appBar: AppBar(
          surfaceTintColor: null,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        body: getEmptyPage()
      );
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        shadowColor: ConstColors.darkGrey,
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
      body: getListedReminderPage(),
      floatingActionButton: getFloatingActionButton()
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
                Navigator.push(context, 
                  MaterialPageRoute(
                    builder: (context) => ReminderPage(
                      thisReminder: Reminder(dateAndTime: DateTime.now().add(Duration(minutes: 5))), 
                      refreshHomePage: refreshPage
                    )
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
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                backgroundColor: Theme.of(context).primaryColor
              ),
            ),
          )
        ],
      ),
    );
  }
Widget getListedReminderPage() {
  return ListView.separated(
    padding: EdgeInsets.symmetric(vertical: 8.0),
    itemCount: 4,
    separatorBuilder: (BuildContext context, int index) => SizedBox(height: 8.0),
    itemBuilder: (BuildContext context, int index) {
      switch (index) {
        case 0:
          return HomePageListSection(
            label: overdueSectionTitle,
            remindersList: remindersMap[overdueSectionTitle] ?? [],
            refreshHomePage: refreshPage,
          );
        case 1:
          return HomePageListSection(
            label: todaySectionTitle,
            remindersList: remindersMap[todaySectionTitle] ?? [],
            refreshHomePage: refreshPage,
          );
        case 2:
          return HomePageListSection(
            label: tomorrowSectionTitle,
            remindersList: remindersMap[tomorrowSectionTitle] ?? [],
            refreshHomePage: refreshPage,
          );
        case 3:
          return HomePageListSection(
            label: laterSectionTitle,
            remindersList: remindersMap[laterSectionTitle] ?? [],
            refreshHomePage: refreshPage,
          );
        default:
          return SizedBox.shrink();
      }
    },
  );
}


  Widget getFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(context, 
          MaterialPageRoute(
            builder: (context) => ReminderPage(
              thisReminder: Reminder(dateAndTime: DateTime.now().add(Duration(minutes: 5))), 
              refreshHomePage: refreshPage
            )
          )
        ); 
      },
      child: const Icon(
        Icons.add,
      )
    );
  }
}