import 'package:flutter/material.dart';
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

enum FieldType {Title, ParsedTime, Time, R_Count, R_Interval, Frequency, None}

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
  // Handling the closing upon appearance of another input widget.
  final _titleFocusNode = FocusNode();
  
  bool _repetitiveNotifsEnabled = false;
  
  @override
  void initState() {
    initialReminder = widget.thisReminder;
    titleParsedReminder = Reminder.deepCopyReminder(widget.thisReminder);

    _titleFocusNode.addListener(_onTitleFocusChange);

    titleParser = TitleParser(
      thisReminder: titleParsedReminder,
      toggleParsedDateTimeField: toggleParsedDateTimeField,
      save: saveTitleParsedReminderOptions,
    );

    super.initState();
  }

  void _onTitleFocusChange() {
    if (_titleFocusNode.hasFocus) {
      currentFieldType = FieldType.Title;
    }
  }

  void _toggleRepetitiveNotifMode(bool value) {
    debugPrint("Repetive Notifs are shut off for a while.");

    // setState(() {
    //   _repetitiveNotifsEnabled = value;
    //   if (currentFieldType == FieldType.R_Count || currentFieldType == FieldType.R_Interval)
    //   {
    //     currentFieldType = FieldType.None;
    //   }
    // });
  }

  /// Save the edits done by the widgets to the reminder
  void saveReminderOptions(Reminder reminder) {
    setState(() {
      debugPrint("[saveReminderOptions] called");
      widget.thisReminder.set(reminder);

      if (titleParsedDateTimeFound)
      {
        titleParsedDateTimeFound = false;
      }
    });
  }


  /// Save the version of reminder parser uses
  void saveTitleParsedReminderOptions(Reminder reminder) {
    setState(() {
      titleParsedReminder = reminder;
    });

    debugPrint("[saveTitleParsed..] parsed: ${titleParsedReminder.dateAndTime}");
    debugPrint("[saveTitleParsed..] parsed: ${widget.thisReminder.dateAndTime}");
  }

  void toggleParsedDateTimeField(bool flag) {
    debugPrint("[togglePar...] $flag");
    setState(() {
      titleParsedDateTimeFound = flag;
    });
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

    void finalDelete() {
      NotificationController.cancelScheduledNotification(
        widget.thisReminder.id.toString()
      );
      RemindersDatabaseController.deleteReminder(widget.thisReminder.id!);
      widget.refreshHomePage();
      Navigator.pop(context);
    }

    if (widget.thisReminder.recurringFrequency != RecurringFrequency.none) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 5,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              'Recurring Reminder',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            content: Text(
              'This is a recurring reminder. Are you sure you want to delete it?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'Cancel',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton(
                onPressed: () { // Reminder won't be deleted unless RF is none.
                  widget.thisReminder.recurringFrequency = RecurringFrequency.none;
                  finalDelete();
                },
                child: Text(
                  'Delete',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          );
        },
      );
    } 
    else 
    {
      finalDelete();
    }
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
      toChange = FieldType.Frequency;
    } 
    else if (fieldType == FieldType.Frequency)
    {
      toChange = FieldType.None;
    }
    else 
    {
      toChange = FieldType.None;
    }


    if (!_repetitiveNotifsEnabled)
    {
      if (toChange == FieldType.R_Count || toChange == FieldType.R_Interval)
      {
        toChange = FieldType.Frequency;
      }
    }

    setState(() {
      currentFieldType = toChange;
    });
  }

  /// Used to set the appropriate input widget when 
  /// the field is tapped.
  void setCurrentInputWidget(FieldType fieldType) {
    debugPrint("called");
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
                    inputFields.dateTimeField(),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Repetitive Notifications',
                            style: theme.textTheme.titleSmall
                          ),
                          Switch(
                            value: _repetitiveNotifsEnabled,
                            onChanged: _toggleRepetitiveNotifMode,
                          ),
                        ],
                      ),
                    ),
                    if (_repetitiveNotifsEnabled)
                      inputFields.repetitionCountField(),
                    if (_repetitiveNotifsEnabled)
                      inputFields.repetitionIntervalField(),
                    inputFields.recurringReminderField()
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
          if (titleParsedDateTimeFound)
            Align(
              alignment: Alignment.bottomCenter,
              child: MaterialContainer(
                elevation: 5,
                child: inputFields.titleParsedDateTimeField()
              )
            ),

          if 
          (
            (currentFieldType != FieldType.Title) &&
            (currentFieldType != FieldType.None) &&
            (!_isKeyboardVisible)
          )
            Align(
              alignment: Alignment.bottomCenter,
              child: MaterialContainer(
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