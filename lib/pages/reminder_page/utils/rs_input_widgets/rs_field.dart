import 'package:flutter/material.dart';
import 'package:Rem/consts/const_colors.dart';
import 'package:Rem/consts/consts.dart';
import 'package:Rem/pages/reminder_page/reminder_page.dart';
import 'package:Rem/reminder_class/reminder.dart';

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
            width: widget.label.length > 10 
            ? reminderSectionFieldsLeftMarginLarge
            : reminderSectionFieldsLeftMarginSmall ,
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
