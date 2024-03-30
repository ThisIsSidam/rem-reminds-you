import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/database/database.dart';
import 'package:nagger/notification/notification.dart';
import 'package:nagger/reminder_class/reminder.dart';
import 'package:nagger/utils/other_utils/snack_bar.dart';
import 'package:nagger/utils/reminder_pg_utils/buttons/bottom_buttons.dart';
import 'package:nagger/utils/other_utils/material_container.dart';
import 'package:nagger/utils/misc_methods/misc_methods.dart';
import 'package:nagger/utils/reminder_pg_utils/rs_input_widgets/input_fields.dart';
import 'package:nagger/utils/reminder_pg_utils/rs_input_widgets/input_section_widget_selecter.dart';
import 'package:nagger/utils/reminder_pg_utils/buttons/section_buttons.dart';
import 'package:nagger/utils/reminder_pg_utils/title_parser/title_parser.dart';

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
  late TitleParser titleParser;
  bool titleParsedDateTimeFound = false;
  late Reminder titleParsedReminder;
  bool _notificationRepeatEnabled = false;

  // Handling the closing upon appearance of another input widget.
  final _titleFocusNode = FocusNode();
  

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

  void _toggleNotificationRepeatMode(bool value) {
    setState(() {
      _notificationRepeatEnabled = value;
      if (currentFieldType == FieldType.R_Count || currentFieldType == FieldType.R_Interval)
      {
        currentFieldType = FieldType.None;
      }
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
    if (widget.thisReminder.title == "No Title")
    {
      showSnackBar(context, "Enter a title!");
      return;
    }
    if (widget.thisReminder.dateAndTime.isBefore(DateTime.now()))
    {
      showSnackBar(context, "Time machine is broke. Can't remind you in the past!");
      return;
    }
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

    if (fieldType == FieldType.Title) 
    {
      toChange = FieldType.Time;
      MiscMethods.removeKeyboard(context);
      _isKeyboardVisible = false;
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

    if (!_notificationRepeatEnabled)
    {
      if (toChange == FieldType.R_Count || toChange == FieldType.R_Interval)
      {
        toChange = FieldType.None;
      }
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

    InputFields inputFields = InputFields(
      context: context, 
      thisReminder: widget.thisReminder, 
      currentFieldType: currentFieldType, 
      titleFocusNode: _titleFocusNode, 
      titleParser: titleParser, 
      titleParsedDateTimeFound: titleParsedDateTimeFound, 
      titleParsedReminder: titleParsedReminder, 
      saveTitleParsedReminderOptions: saveTitleParsedReminderOptions, 
      changeCurrentInputWidget: changeCurrentInputWidget, 
      saveReminderOptions: saveReminderOptions, 
      setCurrentInputWidget: setCurrentInputWidget
    );

    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        scrolledUnderElevation: 5,
        automaticallyImplyLeading: false,
        title: Text(
          "Reminder",
          style: theme.textTheme.titleMedium
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: SectionButtons()
        ),
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
          ListView(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            children: [
              MaterialContainer(
                padding: EdgeInsetsDirectional.all(8),
                elevation: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    inputFields.titleField(),
                    if (titleParsedDateTimeFound)
                      inputFields.titleParsedDateTimeField(),
                    inputFields.dateTimeField(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Repeat Notifications',
                            style: theme.textTheme.titleSmall
                          ),
                          Switch(
                            value: _notificationRepeatEnabled,
                            onChanged: _toggleNotificationRepeatMode,
                          ),
                        ],
                      ),
                    ),
                    if (_notificationRepeatEnabled)
                      inputFields.repetitionCountField(),
                    if (_notificationRepeatEnabled)
                      inputFields.repetitionIntervalField(),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              MaterialContainer(
                padding: EdgeInsetsDirectional.all(8),
                elevation: 5,
                child: BottomButtons.bottomRowButtons(
                  context,
                  initialReminder,
                  saveReminder,
                  widget.thisReminder,
                ),
              ),
            ],
          ),
          if ((currentFieldType != FieldType.Title) &&
              (currentFieldType != FieldType.None) &&
              (!_isKeyboardVisible))
            Align(
              alignment: Alignment.bottomCenter,
              child: MaterialContainer(
                // padding: EdgeInsetsDirectional.all(8),
                elevation: 100,
                child: InputSectionWidgetSelector.showInputSection(
                  currentFieldType,
                  widget.thisReminder,
                  saveReminderOptions,
                  changeCurrentInputWidget,
                ),
              ),
            )
        ],
      ),
    );
  }
}