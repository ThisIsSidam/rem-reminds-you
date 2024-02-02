import 'package:flutter/material.dart';
import 'package:nagger/data/app_theme.dart';
import 'package:nagger/data/reminders_data.dart';
import 'package:nagger/utils/reminder.dart';
import 'package:nagger/utils/time_buttons.dart';

class ReminderPage extends StatefulWidget {
  final Reminder thisReminder;
  final VoidCallback homeRefreshFunc;

  const ReminderPage({
    super.key, 
    required this.thisReminder, 
    required this.homeRefreshFunc
  });

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final RemindersData db = RemindersData();
  final titleController = TextEditingController();

  @override
  void initState() {
    titleController.text = widget.thisReminder.title ?? "";
    super.initState();
  }


  void editTime(Duration dur) {
    setState(() {
      widget.thisReminder.dateAndTime = widget.thisReminder.dateAndTime.add(dur);
    });
  }

  void setTime(String time) {
    final strParts = time.split(" ");

    final timeParts = strParts[0].split(":");
    var hour = int.parse(timeParts[0]);
    var minutes = int.parse(timeParts[1]);

    if (strParts[1] == "PM")
    {
      if (hour != 12)
      {
        hour += 12;
      }
    }

    DateTime updatedTime = DateTime(
      widget.thisReminder.dateAndTime.year,
      widget.thisReminder.dateAndTime.month,
      widget.thisReminder.dateAndTime.day,
      hour,
      minutes
    );
    
    setState(() {
      widget.thisReminder.dateAndTime = updatedTime;
    });
  }
  
  void saveReminder() {
    db.getReminders();

    db.printAll("Before Adding");

    if (widget.thisReminder.id != null)
    {
      print("ID: ${widget.thisReminder.id!}");
      db.deleteReminder(widget.thisReminder.id!);
    }

    widget.thisReminder.title = titleController.text;
    widget.thisReminder.id = widget.thisReminder.getId();
    db.reminders[widget.thisReminder.id!] = widget.thisReminder;
    db.updateReminders();

    db.printAll("After Adding");

    Navigator.pop(context);
    widget.homeRefreshFunc();
  }

  void deleteReminder() {
    db.deleteReminder(widget.thisReminder.id!);
    Navigator.pop(context);
    widget.homeRefreshFunc();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.thisReminder.title ?? "Wake Up To Reality!",
          style: TextStyle(
            color: AppTheme.textOnPrimary
        ),),
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SizedBox(
        child: Column(
          children: [
            const Expanded(
              child: Text("")
            ), 
            SizedBox(
              child: TextFormField(
                controller: titleController,
                style: TextStyle(
                  color: AppTheme.textOnPrimary
                ),
                decoration: InputDecoration(
                  hintText: "Enter title here",
                  hintStyle: TextStyle(
                    color: AppTheme.textOnPrimary
                  ),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    borderSide: BorderSide(color: AppTheme.textOnPrimary)
                  ),
                  fillColor: AppTheme.primaryColor,
                  filled: true
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: Center(
                child: Text(
                  "${widget.thisReminder.getDateTimeAsStr()} ${widget.thisReminder.getDiff()}",
                  style: TextStyle(
                    color: AppTheme.textOnPrimary,
                    fontSize: 20, 
                  ),
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                child: GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  children: [
                    TimeSetButton(time: "9:30 AM", setTime: setTime),
                    TimeSetButton(time: "12:00 PM", setTime: setTime),
                    TimeSetButton(time: "6:30 PM", setTime: setTime),
                    TimeSetButton(time: "10:00 PM", setTime: setTime),
                    TimeEditButton(editDuration: const Duration(minutes: 10), editTime: editTime,),
                    TimeEditButton(editDuration: const Duration(hours: 1), editTime: editTime,),
                    TimeEditButton(editDuration: const Duration(hours: 3), editTime: editTime,),
                    TimeEditButton(editDuration: const Duration(days: 1), editTime: editTime,),
                    TimeEditButton(editDuration: const Duration(minutes: -10), editTime: editTime,),
                    TimeEditButton(editDuration: const Duration(hours: -1), editTime: editTime,),
                    TimeEditButton(editDuration: const Duration(hours: -3), editTime: editTime,),
                    TimeEditButton(editDuration: const Duration(days: -1), editTime: editTime,),
                  ],
                ),
              )
            ), 
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (widget.thisReminder.id != null)
                    MaterialButton(
                      onPressed: () => deleteReminder(),
                      child: const Icon(Icons.delete)
                    ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Close")
                  ),
                  MaterialButton(
                    onPressed: () => saveReminder(),
                    child: const Text("Save")
                  )
                ],
              ),
            )
          ],
        ),
      )
    );
    
  }
}

