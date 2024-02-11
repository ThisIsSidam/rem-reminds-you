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
  var remindersMap = <String,Reminder>{};
  RemindersData db = RemindersData();
  var overdueList= <Reminder>[];
  var todayList = <Reminder>[];
  var tomorrowList = <Reminder>[];
  var laterList = <Reminder>[];

  @override
  void initState() {
    getList();
    super.initState();
  }

  void refreshPage() {
    setState(() {
      getList();
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
        print("Overdue: ${due.inMinutes}");
        overdueList.add(value);
      }
      else if (due.inHours < 24) 
      {
        print("Today: ${due.inMinutes}");
        todayList.add(value);
      }
      else if (due.inHours < 48)
      {
        print("Tomorrow: ${due.inMinutes}");
        tomorrowList.add(value);
      }
      else
      {
        print("Later: ${due.inMinutes}");
        laterList.add(value);
      }
    });
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