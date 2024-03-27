import 'package:flutter/material.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/pages/reminder_page.dart';
import 'package:nagger/reminder_class/reminder.dart';

class RS_Field extends StatefulWidget {
  
  final FieldType fieldType;
  final String label;
  final Reminder thisReminder;
  final Widget fieldWidget;
  final Function(FieldType)? getFocus;

  const RS_Field({
    super.key,
    required this.fieldType,
    required this.label,
    required this.fieldWidget,
    required this.thisReminder,
    this.getFocus,
  }
  );

  @override
  State<RS_Field> createState() => _RS_FieldState();
}

class _RS_FieldState extends State<RS_Field> {

  Widget getWidget() {
    if (widget.getFocus == null)
    {
      return widget.fieldWidget;
    }
    return GestureDetector(
      onTap: () {
        widget.getFocus!(widget.fieldType);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide()
          )
        ),
        child: widget.fieldWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: reminderSectionFieldsLeftMargin,
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.bodyLarge,
            )
          ),
          Expanded(
            child: getWidget(),
          ),
        ],
      ),
    );
  }

}
