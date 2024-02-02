import 'package:flutter/material.dart';
import 'package:nagger/data/app_theme.dart';
import 'package:nagger/pages/reminder_page.dart';
import 'package:nagger/utils/reminder.dart';

class ReminderTile extends StatelessWidget {
  final Reminder thisReminder;
  final VoidCallback refreshFunc;
  const ReminderTile({super.key, required this.thisReminder, required this.refreshFunc});

  Text tileText(String str, {double size = 12}) {
    return Text(
      str,
      style: TextStyle(
        fontSize: size,
        color: AppTheme.textOnPrimary
      ) ,
    );
  }

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
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(5))
          ),  
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  tileText(thisReminder.title ?? "No Text", size: 20),
                  tileText(thisReminder.getDateTimeAsStr())
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    tileText(thisReminder.getDiff()),
                    const SizedBox(height: 20,)
                  ],
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}