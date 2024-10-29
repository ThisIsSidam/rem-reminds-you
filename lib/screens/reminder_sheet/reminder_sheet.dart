import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/screens/reminder_sheet/widgets/date_time_section.dart';
import 'package:Rem/screens/reminder_sheet/widgets/key_buttons_row.dart';
import 'package:Rem/screens/reminder_sheet/widgets/title_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReminderSheet extends ConsumerStatefulWidget {
  final Reminder thisReminder;
  final VoidCallback? refreshHomePage;
  const ReminderSheet({
    super.key,
    required this.thisReminder,
    this.refreshHomePage,
  });

  @override
  ConsumerState<ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends ConsumerState<ReminderSheet> {
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

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedContainer(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        color: theme.scaffoldBackgroundColor,
      ),
      padding: EdgeInsets.only(bottom: keyboardHeight),
      duration: const Duration(milliseconds: 100),
      height: screenHeight * 0.50 + keyboardHeight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TitleField(),
              DateTimeSection(),
              KeyButtonsRow(refreshHomePage: widget.refreshHomePage)
            ],
          ),
        ),
      ),
    );
  }
}
