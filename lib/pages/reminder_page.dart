import 'package:flutter/material.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/database/database.dart';
import 'package:nagger/notification/notification.dart';
import 'package:nagger/reminder_class/reminder.dart';
import 'package:nagger/utils/misc_methods/misc_methods.dart';
import 'package:nagger/utils/rs_field.dart';
import 'package:nagger/utils/rs_input_methods/rs_datetime_input.dart';
import 'package:nagger/utils/rs_input_methods/rs_input_section.dart';
import 'package:nagger/utils/rs_input_methods/rs_rep_count_input.dart';
import 'package:nagger/utils/rs_input_methods/rs_rep_interval_input.dart';

enum FieldType {Title, Time, R_Count, R_Interval, None}

class ReminderPage extends StatefulWidget {
  final Reminder thisReminder;
  final VoidCallback refreshHomePage;
  const ReminderPage({
    super.key, 
    required this.thisReminder,
    required this.refreshHomePage
  });

  @override
  State<ReminderPage> createState() => _ReminderSectionState();
}

class _ReminderSectionState extends State<ReminderPage> {

  late Reminder tempReminder;
  FieldType currentFieldType = FieldType.Title;
  bool _isKeyboardVisible = true;
  final _titleFocusNode = FocusNode();
  final dateTimeFieldFocusNode = FocusNode();
  final repetitionCountFocusNode = FocusNode();
  final repetitionIntervalFocusNode = FocusNode();

  @override
  void initState() {
    tempReminder = widget.thisReminder;
    _titleFocusNode.addListener(_onTitleFocusChange);

    super.initState();
  }

  void _onTitleFocusChange() {
    if (_titleFocusNode.hasFocus)
    {
      currentFieldType = FieldType.Title;
    }
  }

  void saveReminderOptions(Reminder reminder) {
    setState(() {
      widget.thisReminder.set(reminder);
    });
  }

  /// Orders the saving of the reminder in the database.
  void saveReminder() {
    RemindersDatabaseController.saveReminder(
      widget.thisReminder
    );

    widget.refreshHomePage();
    Navigator.pop(context);
  }

  void changeCurrentInputField(FieldType fieldType) {
    FieldType toChange;

    if (fieldType == FieldType.Title)
    {
      toChange = FieldType.Time;
    }
    else if (fieldType == FieldType.Time)
    {
      toChange = FieldType.R_Count;
    }
    else if (fieldType == FieldType.R_Count)
    {
      toChange = FieldType.R_Interval;
    }
    else if (fieldType == FieldType.R_Interval)
    {
      toChange = FieldType.None;
    }
    else
    {
      toChange = FieldType.None;
    }
    
    if (toChange != FieldType.Title)
    {
      MiscMethods.removeKeyboard(context);
      _isKeyboardVisible = false;
    }
    setState(() {
      currentFieldType = toChange;
    });
  }

  void setCurrentInputField(FieldType fieldType) {
    if (currentFieldType == fieldType)
    {
      return;
    }

    setState(() {
      currentFieldType = fieldType;
    });
    debugPrint("[setCurrentInputField] ${currentFieldType}");

    if (currentFieldType != FieldType.Title)
    {
      MiscMethods.removeKeyboard(context);
      _isKeyboardVisible = false;
    }
    else
    {
      _isKeyboardVisible == true;
    }    
  }

  /// Orders the deletion of the reminder from the database.
  void deleteReminder() {
    NotificationController.cancelScheduledNotification(
      widget.thisReminder.id.toString()
    );
    RemindersDatabaseController.deleteReminder(widget.thisReminder.id!);
    widget.refreshHomePage();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reminder"),
        actions: [
          if (widget.thisReminder.id != newReminderID)
          MaterialButton(
            child: IconTheme(
              data: Theme.of(context).iconTheme,
              child: const Icon(Icons.delete)
            ),
            onPressed: () => deleteReminder(),
          ),
        ],
      ),
      body: Stack(
        children:[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleField(context),
              dateTimeField(context),
              repetitionCountField(context),
              repetitionIntervalField(context),
              bottomRowMaterialButtons()
            ],
          ),
          if 
          (
            (currentFieldType != FieldType.Title) && 
            (currentFieldType != FieldType.None) &&
            (!_isKeyboardVisible)
          )
            Align(
              alignment: Alignment.bottomCenter,
              child: showInputField()
            )
        ] 
      ),
    );
  }

  Widget titleField(BuildContext context) {
    return RS_Field(
      fieldType: FieldType.Title, 
      label: "Title", 
      fieldWidget: TextFormField(
        autofocus: true,
        focusNode: _titleFocusNode,
        initialValue: widget.thisReminder.id == newReminderID
        ? null
        : widget.thisReminder.title,
        textCapitalization: TextCapitalization.sentences,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(
            left: 15,
            top: 10,
            bottom: 10,
          ),
          hintStyle: Theme.of(context).textTheme.titleSmall,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
              ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).cardColor),
          ),
        ),
        onChanged: (String str) {
          setState(() {
            widget.thisReminder.title = str;
          });
        },
        onFieldSubmitted: (_) {
          changeCurrentInputField(FieldType.Title);
        },
      ),
      thisReminder: widget.thisReminder, 
      getFocus: setCurrentInputField, 
    );
  }

  Widget dateTimeField(BuildContext context) {
    return RS_Field(
      fieldType: FieldType.Time, 
      label: "Time", 
      fieldWidget: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.thisReminder.getDateTimeAsStr(),
            style: Theme.of(context).textTheme.bodyLarge
          ),
          Text(
            widget.thisReminder.getDiffString(),
            style: Theme.of(context).textTheme.bodyLarge
          ),
        ],
      ), 
      thisReminder: widget.thisReminder, 
      getFocus: setCurrentInputField
    );
  }

  Widget repetitionCountField(BuildContext context) {
    return RS_Field(
      fieldType: FieldType.R_Count, 
      label: "Repeat", 
      fieldWidget: Text(
        "${widget.thisReminder.repetitionCount.toString()} times",
        style: Theme.of(context).textTheme.bodyLarge
      ), 
      thisReminder: widget.thisReminder, 
      getFocus: setCurrentInputField
    );
  }

  Widget repetitionIntervalField(BuildContext context) {
    return RS_Field(
      fieldType: FieldType.R_Interval, 
      label: "Interval", 
      fieldWidget: Text(
        "Every ${widget.thisReminder.getIntervalString()}",
        style: Theme.of(context).textTheme.bodyLarge
      ), 
      thisReminder: widget.thisReminder, 
      getFocus: setCurrentInputField
    );
  }

  Widget showInputField() {
    if (currentFieldType == FieldType.Time)
    {
      return RS_InputSection(
        child: RS_DatetimeInput(
          thisReminder: widget.thisReminder,
          save:  saveReminderOptions,
          moveFocus: changeCurrentInputField,
        ),
      );
    }
    else if (currentFieldType == FieldType.R_Count)
    {
      return RS_InputSection(
        child: RS_RepCountInput(
          thisReminder: widget.thisReminder, 
          save: saveReminderOptions,
          moveFocus: changeCurrentInputField,
        ),
      );
    }
    else
    {
      return RS_InputSection(
        child: RS_RepIntervalInput(
          thisReminder: widget.thisReminder, 
          save: saveReminderOptions,
          moveFocus: changeCurrentInputField,
        ),
      );
    }
  }

  Widget bottomRowMaterialButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MaterialButton(
            child: const Icon(Icons.close),
            onPressed: () {
              widget.thisReminder.set(tempReminder);
              Navigator.pop(context);
            }
          ),
          MaterialButton(
            child: const Icon(Icons.check_circle),
            onPressed: () => saveReminder(),
          )
        ],
      ),
    );
  }

}