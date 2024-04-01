import 'package:flutter/material.dart';
import 'package:nagger/pages/reminder_page.dart';
import 'package:nagger/reminder_class/reminder.dart';

class RS_RepCountInput extends StatelessWidget {
  final Reminder thisReminder;
  final Function(Reminder) save;
  final Function(FieldType) moveFocus;
  final fieldType = FieldType.R_Count;

  const RS_RepCountInput({
    super.key,
    required this.thisReminder,
    required this.save,
    required this.moveFocus
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      mainAxisSpacing: 1,
      crossAxisSpacing: 1,
      crossAxisCount: 3,
      shrinkWrap: true,
      childAspectRatio: 1.5,
      children: [
        countEditButton(3),
        countEditButton(5),
        countEditButton(7),
        countEditButton(10),
        countEditButton(12),
        countEditButton(15),
        countEditButton(20),
        countEditButton(25),
        countEditButton(30),
      ],
    );
  }

  Widget countEditButton(int count) {
    return SizedBox(
      height: 50,
      width: 150,
      child: ElevatedButton(
        onPressed: () {
          thisReminder.repetitionCount = count;
          debugPrint("[repetionCount] tapped button");

          save(thisReminder);
          moveFocus(fieldType);
        }, 
        child: Text(
          count.toString(),
        ),
      ),
    );
  }
}