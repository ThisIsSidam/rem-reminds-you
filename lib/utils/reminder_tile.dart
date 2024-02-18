import 'package:flutter/material.dart';
import 'package:nagger/reminder_class/reminder.dart';
import 'package:nagger/utils/reminder_section.dart';

class ReminderTile extends StatefulWidget {
  final Reminder thisReminder;
  final VoidCallback refreshFunc;
  const ReminderTile({super.key, required this.thisReminder, required this.refreshFunc});

  @override
  State<ReminderTile> createState() => _ReminderTileState();
}

class _ReminderTileState extends State<ReminderTile> {

  Text tileText(String str, {double size = 12}) {
    return Text(
      str,
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: size,
      ) ,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10, right: 10,
      ),
      child: MaterialButton(
        padding: const EdgeInsets.all(0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(5)
          ),
          child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 15, top: 10, bottom: 10
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.thisReminder.title ?? "No Title",
                          style: Theme.of(context).textTheme.titleMedium
                        ),
                        Text(
                          widget.thisReminder.getDateTimeAsStr(),
                          style: Theme.of(context).textTheme.bodyMedium
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 10
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.thisReminder.getDiffString(),
                          style: Theme.of(context).textTheme.bodySmall
                        ),
                        const SizedBox(height: 20,)
                      ],
                    ),
                  ),
                )
              ],
            ),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context, 
            isScrollControlled: true,
            builder: (BuildContext context) => ReminderSection(
              thisReminder: widget.thisReminder, 
              refreshHomePage: widget.refreshFunc
            )
          );
        },
      ),
    );
  }
}