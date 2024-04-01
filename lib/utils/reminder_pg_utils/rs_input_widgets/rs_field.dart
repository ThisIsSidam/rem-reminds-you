import 'package:flutter/material.dart';
import 'package:nagger/consts/const_colors.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/pages/reminder_page.dart';
import 'package:nagger/reminder_class/reminder.dart';

class RS_Field extends StatefulWidget {
  
  final FieldType fieldType;
  final FieldType currentFieldType;
  final String label;
  final Reminder thisReminder;
  final Widget fieldWidget;
  final EdgeInsetsGeometry padding;
  final Function(FieldType)? getFocus;

  const RS_Field({
    super.key,
    required this.fieldType,
    required this.currentFieldType,
    required this.label,
    required this.fieldWidget,
    required this.thisReminder,
    this.padding = const EdgeInsets.all(8),
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
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: widget.currentFieldType == widget.fieldType
              ? Theme.of(context).cardColor
              : ConstColors.lightGrey
            )
          )
        ),
        child: widget.fieldWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Row(
        children: [
          SizedBox(
            width: reminderSectionFieldsLeftMargin,
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.titleSmall,
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
