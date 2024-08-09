import 'package:Rem/utils/other_utils/save_close_buttons.dart';
import 'package:flutter/material.dart';
import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/database.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/other_utils/snack_bar.dart';
import 'package:Rem/utils/functions/misc_methods.dart';
import 'package:Rem/pages/reminder_page/utils/rs_input_widgets/input_fields.dart';
import 'package:Rem/pages/reminder_page/utils/rs_input_widgets/input_section_widget_selecter.dart';
import 'package:Rem/pages/reminder_page/utils/title_parser/title_parser.dart';

enum FieldType {Title, ParsedTime, Time, Rec_Interval, Repeat, None}

class ReminderPage extends StatefulWidget {
  final Reminder thisReminder;
  final VoidCallback? refreshHomePage;
  const ReminderPage({
    super.key,
    required this.thisReminder,
    this.refreshHomePage,
  });

  @override
  State<ReminderPage> createState() => _ReminderSectionState();
}

class _ReminderSectionState extends State<ReminderPage> {
  late Reminder initialReminder;
  FieldType currentFieldType = FieldType.Title;
  // bool _isKeyboardVisible = true;

  late TitleParser titleParser;
  bool titleParsedDateTimeFound = false;
  late Reminder titleParsedReminder;
  // Handling the closing upon appearance of another input widget.
  final _titleFocusNode = FocusNode();
  
  @override
  void initState() {

    initialReminder = widget.thisReminder.deepCopyReminder();
    titleParsedReminder = widget.thisReminder.deepCopyReminder();

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

  /// Save the edits done by the widgets to the reminder
  void saveReminderOptions(Reminder reminder) {
    setState(() {
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
  }

  void toggleParsedDateTimeField(bool flag) {
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
    refreshOrExit();
  }

  void deleteReminder() {

    void finalDelete({deleteAllRecurring = false}) {
      RemindersDatabaseController.deleteReminder(
        widget.thisReminder.id!,
        allRecurringVersions: deleteAllRecurring
      );
      refreshOrExit();
    }

    if (widget.thisReminder.recurringInterval != RecurringInterval.none) {
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
              'This is a recurring reminder.',
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
                onPressed: () {
                  finalDelete(deleteAllRecurring: false);
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'Delete This Only',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              TextButton(
                onPressed: () { // Reminder won't be deleted unless RF is none.
                  widget.thisReminder.recurringInterval = RecurringInterval.none;
                  finalDelete(deleteAllRecurring: true);
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'Delete All',
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
      // _isKeyboardVisible = false;
    } 
    else if (fieldType == FieldType.Time) 
    {
      toChange = FieldType.Rec_Interval;
    } 
    else if (fieldType == FieldType.Rec_Interval) 
    {
      toChange = FieldType.Repeat;
    } 
    else if (fieldType == FieldType.Repeat)
    {
      toChange = FieldType.None;
    }
    else 
    {
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

    // if (currentFieldType != FieldType.Title) {
    //   MiscMethods.removeKeyboard(context);
    //   _isKeyboardVisible = false;
    // } else {
    //   _isKeyboardVisible = true;
    // }
  }


  @override
  void dispose() {
    super.dispose();
  }

  void refreshOrExit() {
    if (widget.refreshHomePage == null)
    {
      Navigator.pop(context);
      return;
    }

    widget.refreshHomePage!();
    Navigator.pop(context);
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
    return Container(
      constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height * 0.9),
      height: MediaQuery.sizeOf(context).height * 0.9,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          pseudoAppBar(),
          Container(
            padding: EdgeInsetsDirectional.all(8),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(blurRadius: 2, blurStyle: BlurStyle.normal)
              ]
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                inputFields.titleField(),
                inputFields.dateTimeField(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    inputFields.repeatNotifInterval(),
                    inputFields.recurringReminderField(),
                  ],
                ),
                SizedBox(height: 20,),
                if (titleParsedDateTimeFound)
                    inputFields.titleParsedDateTimeField(),
              ],
            ),
          ),
          SizedBox(height: 20,),
          Container(
            height: MediaQuery.sizeOf(context).height * 0.5,
            alignment: Alignment.topCenter,
            padding: EdgeInsetsDirectional.all(8),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(blurRadius: 2, blurStyle: BlurStyle.normal)
              ]
            ),
            child: currentFieldType != FieldType.None 
            ? InputSectionWidgetSelector.showInputSection(
              currentFieldType,
              widget.thisReminder,
              saveReminderOptions,
              changeCurrentInputWidget,
            )
            : SaveCloseButtons(
                onTapSave: saveReminder,
                onTapClose: () {
                  widget.thisReminder.set(initialReminder);
                  refreshOrExit();
                },
              ),
          )
        ],
      ),
    );
  }

  Widget pseudoAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Reminder",
            style: Theme.of(context).textTheme.titleMedium
          ),
          Row( // Actions Row
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Don't show delete button for reminders which haven't yet been saved even once
              // Or for archived reminders coz their delete button is outside.
              if ( 
                widget.thisReminder.id != newReminderID && 
                widget.thisReminder.reminderStatus != ReminderStatus.archived
              )
                MaterialButton(
                  child: IconTheme(
                    data: Theme.of(context).iconTheme,
                    child: const Icon(Icons.delete),
                  ),
                  onPressed: () => deleteReminder(),
                ),
            ]
          )
        ],
      ),
    );
  }
}