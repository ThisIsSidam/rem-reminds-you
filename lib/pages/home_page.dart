import 'package:flutter/material.dart';
import 'package:nagger/data/app_theme.dart';
import 'package:nagger/data/reminders_data.dart';
import 'package:nagger/pages/reminder_page.dart';
import 'package:nagger/utils/reminder.dart';
import 'package:nagger/utils/reminder_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var remindersMap = <String,Reminder>{};
  RemindersData db = RemindersData();
  var remindersList = <Reminder>[];

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

    remindersList = [];
    remindersMap.forEach((key, value) {remindersList.add(value);});
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
      body: ListView.builder(
        itemCount: remindersList.length,
        itemBuilder: (context, index) {
          return ReminderTile(
            thisReminder: remindersList[index], 
            refreshFunc: refreshPage,
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: ((context) => ReminderPage(
                thisReminder: Reminder(
                  dateAndTime: DateTime.now().add(const Duration(minutes: 5))
                ), 
                homeRefreshFunc: refreshPage,
              ))
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