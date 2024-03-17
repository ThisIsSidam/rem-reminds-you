import 'package:flutter/material.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/database/database.dart';
import 'package:nagger/notification/notification.dart';
import 'package:nagger/reminder_class/reminder.dart';
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
  DateTime tempDateTime = DateTime.now();

  @override
  void initState() {
    if (widget.thisReminder.id != 101)
    {
      titleController.text = widget.thisReminder.title ?? reminderNullTitle;
    }
    tempDateTime = widget.thisReminder.dateAndTime;
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
      minutes,
    );
    
    setState(() {
      widget.thisReminder.dateAndTime = updatedTime;
    });
  }

  void saveReminder() {
    db.getReminders();

    db.printAll("Before Adding");

    if (widget.thisReminder.id != 101)
    {
      NotificationController.cancelScheduledNotification(
        widget.thisReminder.id ?? reminderNullID
      );
      db.deleteReminder(widget.thisReminder.id!);
    }

    widget.thisReminder.title = titleController.text;
    widget.thisReminder.id = widget.thisReminder.getID();
    db.reminders[widget.thisReminder.id!] = widget.thisReminder;
    NotificationController.scheduleNotification(
      widget.thisReminder.id ?? reminderNullID,
      widget.thisReminder.title ?? reminderNullTitle,
      widget.thisReminder.dateAndTime
    );
    
    db.updateReminders();
    db.printAll("After Adding");

    widget.refreshHomePage();
    Navigator.pop(context);
  }

  void deleteReminder() {
    NotificationController.cancelScheduledNotification(
      widget.thisReminder.id ?? reminderNullID
    );
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
      heightFactor: 0.85,
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20,),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: TextFormField(
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
                controller: titleController,
                style: Theme.of(context).textTheme.titleMedium,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(
                    left: 15, top: 10, bottom: 10
                  ),
                  hintText: "New Reminder... Enter title here",
                  hintStyle: Theme.of(context).textTheme.titleSmall,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 15, top: 10, bottom: 10, 
              ),
              child: Text("${widget.thisReminder.getDateTimeAsStr()} · ${widget.thisReminder.getDiffString()}"),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: GridView.count(
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                crossAxisCount: 4,
                shrinkWrap: true,
                childAspectRatio: 1.5,
                children: [
                  TimeSetButton(time: timeSetButton0930AM, setTime: setTime),
                  TimeSetButton(time: timeSetButton12PM, setTime: setTime),
                  TimeSetButton(time: timeSetButton0630PM, setTime: setTime),
                  TimeSetButton(time: timeSetButton10PM, setTime: setTime),
                  // Durations of some are altered to quickly get notifications. Will change later on.
                  TimeEditButton(editDuration: const Duration(seconds: 5), editTime: editTime,),
                  TimeEditButton(editDuration: const Duration(minutes: 1), editTime: editTime,),
                  TimeEditButton(editDuration: const Duration(hours: 3), editTime: editTime,),
                  TimeEditButton(editDuration: const Duration(days: 1), editTime: editTime,),
                  TimeEditButton(editDuration: const Duration(seconds: -5), editTime: editTime,),
                  TimeEditButton(editDuration: const Duration(minutes: -1), editTime: editTime,),
                  TimeEditButton(editDuration: const Duration(hours: -3), editTime: editTime,),
                  TimeEditButton(editDuration: const Duration(days: -1), editTime: editTime,),
                ],
              ),
            ), 
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (widget.thisReminder.id != 101)
                  MaterialButton(
                    onPressed: () => deleteReminder(),
                    child: IconTheme(
                      data: Theme.of(context).iconTheme,
                      child: const Icon(Icons.delete)
                    ),
                  ),
                  MaterialButton(
                    child: Text(
                      materialButtonCloseText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onPressed: () {
                      widget.thisReminder.dateAndTime = tempDateTime;
                      Navigator.pop(context);
                    }
                  ),
                  MaterialButton(
                    onPressed: () => saveReminder(),
                    child: Text(
                      materialButtonSaveText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
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