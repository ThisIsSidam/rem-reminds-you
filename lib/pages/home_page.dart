import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nagger/data/app_theme.dart';
import 'package:nagger/data/reminders_data.dart';
import 'package:nagger/utils/homepage_list_section.dart';
import 'package:nagger/utils/reminder.dart';
import 'package:nagger/utils/reminder_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  bool firstTime = true;
  var remindersMap = <String,Reminder>{};
  RemindersData db = RemindersData();
  var overdueList= <Reminder>[];
  var todayList = <Reminder>[];
  var tomorrowList = <Reminder>[];
  var laterList = <Reminder>[];

  @override
  void initState() {
    getList();

    _scheduleRefresh();

    super.initState();
  }

  void _scheduleRefresh() {
    DateTime now = DateTime.now();
    Duration timeUntilNextRefresh = Duration(
      seconds: 60 - now.second,
      milliseconds: 1000 - now.millisecond
    );

    _timer = Timer(timeUntilNextRefresh, () {
      refreshPage();

      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        refreshPage();
      });
    });
  }

  void refreshPage() {
    setState(() {
      getList();
      print("refrshPage Called");
    });
  }

  void getList() {
    db.getReminders();
    remindersMap = db.reminders;

    overdueList = [];
    todayList = [];
    tomorrowList = [];
    laterList = [];

    remindersMap.forEach((key, value) {
      Duration due = value.getDiffDuration();
      if (due.isNegative)
      {
        overdueList.add(value);
      }
      else if (due.inHours < 24) 
      {
        todayList.add(value);
      }
      else if (due.inHours < 48)
      {
        tomorrowList.add(value);
      }
      else
      {
        laterList.add(value);
      }
    });

    print("Refreshed");
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
          style: TextStyle(
            color: AppTheme.textOnPrimary
          ),
          ),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            onPressed: () => refreshPage(), 
            icon: Icon(
              Icons.refresh,
              color: AppTheme.textOnPrimary,
            )
          )
        ]
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
        backgroundColor: AppTheme.primaryColor,
        onPressed: () {
          showModalBottomSheet(
            context: context, 
            isScrollControlled: true,
            builder: (BuildContext context) => ReminderSection(
              thisReminder: Reminder(
                dateAndTime: DateTime.now().add(const Duration(minutes: 5))
              ), 
              refreshHomePage: refreshPage
            )
          );
        },
        child: Icon(
          Icons.add,
          color: AppTheme.textOnPrimary,
        )
      ),
    );
  }
}