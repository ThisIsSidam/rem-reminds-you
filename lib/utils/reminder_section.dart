import 'package:flutter/material.dart';
import 'package:nagger/data/app_theme.dart';
import 'package:nagger/data/reminders_data.dart';
import 'package:nagger/utils/reminder.dart';
import 'package:nagger/utils/time_edit_button.dart';
import 'package:nagger/utils/time_set_button.dart';

class ReminderSection extends StatefulWidget {
  final Reminder thisReminder;
  final VoidCallback refreshHomePage;
  const ReminderSection({
    super.key, 
    required this.thisReminder,
    required this.refreshHomePage
  });

  @override
  State<ReminderSection> createState() => _ReminderSectionState();
}

class _ReminderSectionState extends State<ReminderSection> {

  RemindersData db = RemindersData();
  TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    if (widget.thisReminder.id != "new")
    {
      titleController.text = widget.thisReminder.title ?? "No Title 2";
    }
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

    if (widget.thisReminder.id != "new")
    {
      print("ID: ${widget.thisReminder.id!}");
      db.deleteReminder(widget.thisReminder.id!);
    }
    
    widget.thisReminder.title = titleController.text;
    widget.thisReminder.id = widget.thisReminder.getId();
    db.reminders[widget.thisReminder.id!] = widget.thisReminder;
    
    db.updateReminders();
    db.printAll("After Adding");

    widget.refreshHomePage();
    Navigator.pop(context);
  }

  void deleteReminder() {
    db.deleteReminder(widget.thisReminder.id!);
    widget.refreshHomePage();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20,),
          TextFormField(
            autofocus: true,
              controller: titleController,
              style: TextStyle(
                color: AppTheme.textOnPrimary,
                fontSize: 20
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(
                  left: 15, top: 10, bottom: 10
                ),
                hintText: "New Reminder... Enter title here",
                hintStyle: TextStyle(
                  color: AppTheme.textOnPrimary
                ),
                border: const OutlineInputBorder()
              ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 15, top: 10, bottom: 10, 
            ),
            child: Text("${widget.thisReminder.getDateTimeAsStr()} · ${widget.thisReminder.getDiffString()}"),
          ),
          SizedBox(
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              childAspectRatio: 1.5,
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
                if (widget.thisReminder.id != "new")
                  MaterialButton(
                    onPressed: () => deleteReminder(),
                    child: const Icon(Icons.delete)
                  ),
                MaterialButton(
                  child: const Text("Close"),
                  onPressed: () {
                    Navigator.pop(context);
                  }
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
    );
  }
}