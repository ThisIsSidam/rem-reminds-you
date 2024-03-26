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
  FocusManager.instance.primaryFocus?.unfocus();
    return FractionallySizedBox(
      heightFactor: 0.45,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: GridView.count(
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          crossAxisCount: 2,
          shrinkWrap: true,
          childAspectRatio: 1.5,
          children: [
            countEditButton(3),
            countEditButton(5),
            countEditButton(10),
            countEditButton(15),
          ],
        ),
      ),
    );
  }

  Widget countEditButton(int count) {
    return SizedBox(
      height: 75,
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