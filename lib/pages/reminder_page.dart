import 'package:flutter/material.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/database/database.dart';
import 'package:nagger/notification/notification.dart';
import 'package:nagger/reminder_class/reminder.dart';
import 'package:nagger/utils/bottom_buttons.dart';
import 'package:nagger/utils/misc_methods/misc_methods.dart';
import 'package:nagger/utils/rs_input_widgets/input_fields.dart';
import 'package:nagger/utils/rs_input_widgets/input_section_widget_selecter.dart';
import 'package:nagger/utils/title_parser/title_parser.dart';

enum FieldType { Title, ParsedTime, Time, R_Count, R_Interval, None }

class ReminderPage extends StatefulWidget {
  final Reminder thisReminder;
  final VoidCallback refreshHomePage;
  const ReminderPage({
    super.key,
    required this.thisReminder,
    required this.refreshHomePage,
  });

  @override
  State<ReminderPage> createState() => _ReminderSectionState();
}

class _ReminderSectionState extends State<ReminderPage> {
  late Reminder initialReminder;
  FieldType currentFieldType = FieldType.Title;
  bool _isKeyboardVisible = true;
  final _titleFocusNode = FocusNode();
  late TitleParser titleParser;
  bool titleParsedDateTimeFound = false;
  late Reminder titleParsedReminder;
  bool _notificationRepeatEnabled = true;

  @override
  void initState() {
    initialReminder = widget.thisReminder;
    titleParsedReminder = Reminder.deepCopyReminder(widget.thisReminder);

    _titleFocusNode.addListener(_onTitleFocusChange);

    titleParser = TitleParser(
      thisReminder: titleParsedReminder,
      save: saveTitleParsedReminderOptions,
    );

    super.initState();
  }

  void _onTitleFocusChange() {
    if (_titleFocusNode.hasFocus) {
      currentFieldType = FieldType.Title;
    }
  }

  void _toggleRepeatMode(bool value) {
    setState(() {
      _notificationRepeatEnabled = value;
    });
  }

  /// Save the edits done by the widgets to the reminder
  void saveReminderOptions(Reminder reminder) {
    setState(() {
      debugPrint("[saveReminderOptions] called");
      widget.thisReminder.set(reminder);
    });
  }


  /// Save the version of reminder parser uses
  void saveTitleParsedReminderOptions(Reminder reminder) {
    setState(() {
      titleParsedReminder = reminder;
      titleParsedDateTimeFound = true; // Set titleParsedDateTimeFound to true
    });

    debugPrint("[saveTitleParsed..] parsed: ${titleParsedReminder.dateAndTime}");
    debugPrint("[saveTitleParsed..] parsed: ${widget.thisReminder.dateAndTime}");
  }

  void saveReminder() {
    RemindersDatabaseController.saveReminder(widget.thisReminder);
    widget.refreshHomePage();
    Navigator.pop(context);
  }

  void deleteReminder() {
    NotificationController.cancelScheduledNotification(
        widget.thisReminder.id.toString());
    RemindersDatabaseController.deleteReminder(widget.thisReminder.id!);
    widget.refreshHomePage();
    Navigator.pop(context);
  }

  /// Moves the currentInputField to the one after it.
  /// Used after the value is selected and there is no more
  /// need of the inputWidget.
  void changeCurrentInputWidget(FieldType fieldType) {
    FieldType toChange;

    if (fieldType == FieldType.Title) {
      toChange = FieldType.Time;
      MiscMethods.removeKeyboard(context);
      _isKeyboardVisible = false;
    } else if (fieldType == FieldType.Time) {
      toChange = FieldType.R_Count;
    } else if (fieldType == FieldType.R_Count) {
      toChange = FieldType.R_Interval;
    } else if (fieldType == FieldType.R_Interval) {
      toChange = FieldType.None;
    } else {
      toChange = FieldType.None;
    }

    setState(() {
      currentFieldType = toChange;
    });
  }

  /// Used to set the appropriate input widget when 
  /// the field is tapped.
  void setCurrentInputWidget(FieldType fieldType) {
    if (currentFieldType == fieldType) {
      return;
    }

    setState(() {
      currentFieldType = fieldType;
    });
    debugPrint("[setCurrentInputField] ${currentFieldType}");

    if (currentFieldType != FieldType.Title) {
      MiscMethods.removeKeyboard(context);
      _isKeyboardVisible = false;
    } else {
      _isKeyboardVisible = true;
    }
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reminder"),
        actions: [
          if (widget.thisReminder.id != newReminderID)
            MaterialButton(
              child: IconTheme(
                data: Theme.of(context).iconTheme,
                child: const Icon(Icons.delete),
              ),
              onPressed: () => deleteReminder(),
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputFields.titleField(
                context,
                widget.thisReminder,
                _titleFocusNode,
                titleParser,
                titleParsedDateTimeFound,
                titleParsedReminder,
                saveTitleParsedReminderOptions,
                changeCurrentInputWidget,
              ),
              if (titleParsedDateTimeFound)
                InputFields.titleParsedDateTimeField(
                  context,
                  titleParsedReminder,
                  saveReminderOptions,
                ),
              InputFields.dateTimeField(
                context,
                widget.thisReminder,
                setCurrentInputWidget,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Repeat'),
                    Switch(
                      value: _notificationRepeatEnabled,
                      onChanged: _toggleRepeatMode,
                    ),
                  ],
                ),
              ),
              if (_notificationRepeatEnabled)
                InputFields.repetitionCountField(
                  context,
                  widget.thisReminder,
                  setCurrentInputWidget,
                ),
              if (_notificationRepeatEnabled)
                InputFields.repetitionIntervalField(
                  context,
                  widget.thisReminder,
                  setCurrentInputWidget,
                ),
              BottomButtons.bottomRowButtons(
                context,
                initialReminder,
                saveReminder,
                widget.thisReminder,
              ),
            ],
          ),
          if ((currentFieldType != FieldType.Title) &&
              (currentFieldType != FieldType.None) &&
              (!_isKeyboardVisible))
            Align(
              alignment: Alignment.bottomCenter,
              child: InputSections.showInputSection(
                currentFieldType,
                widget.thisReminder,
                saveReminderOptions,
                changeCurrentInputWidget,
              ),
            )
        ],
      ),
    );
  }
}