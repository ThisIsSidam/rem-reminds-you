import 'package:flutter/material.dart';
import 'package:nagger/pages/reminder_page.dart';
import 'package:nagger/utils/reminder.dart';

class ReminderTile extends StatelessWidget {
  final Reminder thisReminder;
  final VoidCallback refreshFunc;
  const ReminderTile({super.key, required this.thisReminder, required this.refreshFunc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10, 
        left: 10,
        right: 10
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: ((context) => ReminderPage(
                thisReminder: thisReminder, 
                homeRefreshFunc: refreshFunc,
              ))
            )
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.all(Radius.circular(5))
          ),  
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thisReminder.title ?? "Wake Up To Reality!",
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    thisReminder.getDateTimeAsStr(),
                  )
                ],
              ),
              // const SizedBox(width: 100,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    child: Text(
                      thisReminder.getDiff(),
                    ),
                  ),
                  const SizedBox(height: 20,)
                ],
              )
            ],
          )
        ),
      ),
    );
  }
}