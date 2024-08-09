import 'package:Rem/pages/reminder_page/utils/date_time_field.dart';
import 'package:Rem/pages/reminder_page/utils/key_buttons_row.dart';
import 'package:Rem/pages/reminder_page/utils/time_edit_grid.dart';
import 'package:Rem/pages/reminder_page/utils/title_field.dart';
import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:flutter/material.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/functions/misc_methods.dart';
import 'package:Rem/pages/reminder_page/utils/title_parser/title_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FieldType {Title, ParsedTime, Time, Rec_Interval, Repeat, None}

class ReminderPage extends ConsumerStatefulWidget {
  final Reminder thisReminder;
  final VoidCallback? refreshHomePage;
  const ReminderPage({
    super.key,
    required this.thisReminder,
    this.refreshHomePage,
  });

  @override
  ConsumerState<ReminderPage> createState() => _ReminderSectionState();
}

class _ReminderSectionState extends ConsumerState<ReminderPage> {
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

    final reminderProvider = ref.read(reminderNotifierProvider.notifier);

    Future(() {
      reminderProvider.updateReminder(initialReminder);
    });

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

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height * 0.95),
      height: MediaQuery.sizeOf(context).height * 0.95,
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          TitleField(),
          DateTimeField(),
          QuickAccessTimeTable(),
          KeyButtonsRow(refreshHomePage: widget.refreshHomePage)
        ],
      )
    );
  }
}