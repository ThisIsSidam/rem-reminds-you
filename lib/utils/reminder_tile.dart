import 'package:flutter/material.dart';
import 'package:nagger/data/app_theme.dart';
import 'package:nagger/data/reminders_data.dart';
import 'package:nagger/utils/reminder.dart';
import 'package:nagger/utils/time_buttons.dart';

class ReminderTile extends StatefulWidget {
  final Reminder thisReminder;
  final VoidCallback refreshFunc;
  const ReminderTile({super.key, required this.thisReminder, required this.refreshFunc});

  @override
  State<ReminderTile> createState() => _ReminderTileState();
}

class _ReminderTileState extends State<ReminderTile> {
  final tileController = ExpansionTileController();
  final RemindersData db = RemindersData();
  final titleController = TextEditingController();

  @override
  void initState() {
    titleController.text = widget.thisReminder.title ?? "";
    super.initState();
  }

  Text tileText(String str, {double size = 12}) {
    return Text(
      str,
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: size,
        color: AppTheme.textOnPrimary
      ) ,
    );
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

    tileController.collapse();
    widget.refreshFunc();
  }

  void deleteReminder() {
    db.deleteReminder(widget.thisReminder.id!);
    tileController.collapse();
    widget.refreshFunc();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(10.0)
        ),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          controller: tileController,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: titleController,
                style: TextStyle(
                  color: AppTheme.textOnPrimary,
                  fontSize: 20
                ),
                decoration: InputDecoration(
                  hintText: "New Reminder... Enter title here",
                  hintStyle: TextStyle(
                    color: AppTheme.textOnPrimary
                  ),
                  border: InputBorder.none,
                ),
                onTap: () {
                  if (!tileController.isExpanded)
                  {
                    tileController.expand();
                  }
                },
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              tileText(widget.thisReminder.getDateTimeAsStr(), size: 15),
            ],
          ),
          children: [
            SizedBox(
              child: Column(
                children: [
                  SizedBox(
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
                  ), 
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        MaterialButton(
                          onPressed: () => deleteReminder(),
                          child: const Icon(Icons.delete)
                        ),
                        MaterialButton(
                          onPressed: () {
                            tileController.collapse();
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
          ],
        ),
      ),
    );
  }
}