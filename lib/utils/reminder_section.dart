import 'package:flutter/material.dart';
import 'package:nagger/data/reminders_data.dart';
import 'package:nagger/utils/notification.dart';
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
  LocalNotificationService notifs = LocalNotificationService();
  TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    if (widget.thisReminder.id != 101)
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
      notifs.cancelScheduledNotification(
        widget.thisReminder.id ?? 7
      );
      db.deleteReminder(widget.thisReminder.id!);
    }

    widget.thisReminder.title = titleController.text;
    widget.thisReminder.id = widget.thisReminder.getID();
    db.reminders[widget.thisReminder.id!] = widget.thisReminder;
    notifs.scheduleNotification(
      widget.thisReminder.id ?? 7,
      widget.thisReminder.title ?? "Rando",
      widget.thisReminder.dateAndTime
    );
    
    db.updateReminders();
    db.printAll("After Adding");

    widget.refreshHomePage();
    Navigator.pop(context);
  }

  void deleteReminder() {
    notifs.cancelScheduledNotification(
      widget.thisReminder.id ?? 7
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
                      "Close",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }
                  ),
                  MaterialButton(
                    onPressed: () => saveReminder(),
                    child: Text(
                      "Save",
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