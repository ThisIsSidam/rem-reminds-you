import 'package:Rem/pages/reminder_page/utils/date_time_field.dart';
import 'package:Rem/pages/reminder_page/utils/key_buttons_row.dart';
import 'package:Rem/pages/reminder_page/utils/time_edit_grid.dart';
import 'package:Rem/pages/reminder_page/utils/title_field.dart';
import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  
  @override
  void initState() {

    initialReminder = widget.thisReminder.deepCopyReminder();

    final reminderProvider = ref.read(reminderNotifierProvider.notifier);

    Future(() {
      reminderProvider.updateReminder(initialReminder);
      
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final screenHeight = MediaQuery.of(context).size.height;
        
        return AnimatedContainer(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            color: theme.scaffoldBackgroundColor,
          ),
          padding: EdgeInsets.only(bottom: keyboardHeight),
          duration: const Duration(milliseconds: 100),
          height: screenHeight * 0.55 + keyboardHeight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TitleField(),
                  DateTimeField(),
                  QuickAccessTimeTable(),
                  KeyButtonsRow(refreshHomePage: widget.refreshHomePage)
                ],
              ),
            ),
          ),
        );
      }  
    );
  }
}