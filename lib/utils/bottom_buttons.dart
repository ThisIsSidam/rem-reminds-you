import 'package:flutter/material.dart';
import 'package:nagger/reminder_class/reminder.dart';

class BottomButtons {
  static Widget bottomRowButtons(
    BuildContext context,
    Reminder initialReminder,
    void Function() saveReminder,
    Reminder thisReminder,
  ) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          bottomRowButton(
            "Close",
            () {
              thisReminder.set(initialReminder);
              Navigator.pop(context);
            },
          ),
          bottomRowButton(
            "Save",
            saveReminder,
          ),
        ],
      ),
    );
  }

  static Widget bottomRowButton(String label, void Function() onTap) {
    return SizedBox(
      height: 50,
      width: 100,
      child: ElevatedButton(
        child: Text(label),
        onPressed: onTap,
      ),
    );
  }
}