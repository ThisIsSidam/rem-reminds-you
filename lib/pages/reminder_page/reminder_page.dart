import 'package:Rem/pages/reminder_page/utils/date_time_field.dart';
import 'package:Rem/pages/reminder_page/utils/key_buttons_row.dart';
import 'package:Rem/pages/reminder_page/utils/time_edit_grid.dart';
import 'package:Rem/pages/reminder_page/utils/title_field.dart';
import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:flutter/material.dart';
import 'package:Rem/reminder_class/reminder.dart';
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

  late TitleParseHandler titleParser;
  bool titleParsedDateTimeFound = false;
  late Reminder titleParsedReminder;
  
  @override
  void initState() {

    initialReminder = widget.thisReminder.deepCopyReminder();
    titleParsedReminder = widget.thisReminder.deepCopyReminder();

    final reminderProvider = ref.read(reminderNotifierProvider.notifier);

    Future(() {
      reminderProvider.updateReminder(initialReminder);
    });



    super.initState();
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