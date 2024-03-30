import 'package:flutter/material.dart';
import 'package:nagger/consts/const_colors.dart';
import 'package:nagger/reminder_class/reminder.dart';

class BottomButtons {
  static Widget bottomRowButtons(
    BuildContext context,
    Reminder initialReminder,
    void Function() saveReminder,
    Reminder thisReminder,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: bottomRowButton(
              context,
              "Close",
              () {
                thisReminder.set(initialReminder);
                Navigator.pop(context);
              }, 
              ConstColors.lightGrey
            ),
          ),
          SizedBox(width: 10,),
          Expanded(
            flex: 3,
            child: bottomRowButton(
              context,
              "Save",
              saveReminder,
              ConstColors.blue
            ),
          ),
        ],
      ),
    );
  }

  static Widget bottomRowButton(
    BuildContext context,
    String label, 
    void Function() onTap, 
    Color color,
  ) {
    return SizedBox(
      height: 50,
      width: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)
          )
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        onPressed: onTap,
      ),
    );
  }
}