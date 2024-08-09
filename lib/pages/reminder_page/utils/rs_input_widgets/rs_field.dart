import 'package:flutter/material.dart';
import 'package:Rem/pages/reminder_page/reminder_page.dart';
import 'package:Rem/reminder_class/reminder.dart';

class RS_Field extends StatefulWidget {
  
  final FieldType fieldType;
  final FieldType currentFieldType;
  final String? label;
  final Reminder thisReminder;
  final Widget fieldWidget;
  final EdgeInsetsGeometry padding;
  final Function(FieldType)? getFocus;

  const RS_Field({
    super.key,
    required this.fieldType,
    required this.currentFieldType,
    this.label,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,

      child: (widget.getFocus == null)
            
      ? widget.fieldWidget
             
      : ElevatedButton(
          onPressed: () {widget.getFocus!(widget.fieldType);},
          style: Theme.of(context).elevatedButtonTheme.style,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 16
                ),
                child: widget.fieldWidget,
              ),
              if(widget.label != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                  widget.label!,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontSize: 12
                  ),
                                ),
                ),  
            ],
          )
        ),
    );
  }

}

