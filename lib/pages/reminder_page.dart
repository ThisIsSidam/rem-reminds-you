import 'package:flutter/material.dart';
import 'package:nagger/utils/reminder.dart';
import 'package:nagger/utils/time_buttons.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {

  static Reminder newReminder = Reminder(
    dateAndTime: DateTime.now().add(const Duration(minutes: 5))
  );

  void editTime(Duration dur) {
    setState(() {
      newReminder.dateAndTime = newReminder.dateAndTime!.add(dur);
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
      newReminder.dateAndTime!.year,
      newReminder.dateAndTime!.month,
      newReminder.dateAndTime!.day,
      hour,
      minutes
    );
    
    setState(() {
      newReminder.dateAndTime = updatedTime;
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    newReminder.dateAndTime = DateTime.now().add(const Duration(minutes: 5));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((newReminder.title == "") ? "New Reminder" : newReminder.title!),
        automaticallyImplyLeading: false,
      ),
      body: SizedBox(
        child: Column(
          children: [
            const Expanded(
              child: Text("")
            ), 
            SizedBox(
              child: TextFormField(
                initialValue: (newReminder.title == "") ? "" : newReminder.title,
                decoration: const InputDecoration(
                  hintText: "Enter title here",
                  border: OutlineInputBorder()
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: Text(
                newReminder.getDateTimeAsStr(),
                style: const TextStyle(
                  fontSize: 20,
                  
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
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Close")
                  ),
                  MaterialButton(
                    onPressed: () {},
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

