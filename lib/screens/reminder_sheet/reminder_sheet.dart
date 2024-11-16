import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:Rem/provider/settings_provider.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/screens/reminder_sheet/providers/bottom_element_provider.dart';
import 'package:Rem/screens/reminder_sheet/widgets/bottom_elements/recurrence_options.dart';
import 'package:Rem/screens/reminder_sheet/widgets/bottom_elements/snooze_options.dart';
import 'package:Rem/screens/reminder_sheet/widgets/date_time_section.dart';
import 'package:Rem/screens/reminder_sheet/widgets/key_buttons_row.dart';
import 'package:Rem/screens/reminder_sheet/widgets/title_field.dart';
import 'package:Rem/utils/logger/global_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReminderSheet extends ConsumerStatefulWidget {
  final Reminder thisReminder;
  const ReminderSheet({
    super.key,
    required this.thisReminder,
  });

  @override
  ConsumerState<ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends ConsumerState<ReminderSheet> {
  late Reminder initialReminder;

  @override
  void initState() {
    gLogger.i('Build Reminder Sheet');
    initialReminder = widget.thisReminder.deepCopyReminder();
    initialReminder.autoSnoozeInterval =
        ref.read(userSettingsProvider).defaultAutoSnoozeDuration;

    final reminderProvider = ref.read(reminderNotifierProvider.notifier);

    Future(() {
      reminderProvider.updateReminder(initialReminder);
      ref.read(bottomElementProvider).setAsNone();
      gLogger.i("Reminder initialized and bottom element set to none");
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedContainer(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        color: theme.scaffoldBackgroundColor,
      ),
      padding: EdgeInsets.only(bottom: keyboardHeight),
      duration: const Duration(milliseconds: 100),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TitleField(),
              DateTimeSection(),
              KeyButtonsRow(),
              _buildBottomElement()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomElement() {
    final element = ref.watch(bottomElementProvider).element;
    if (element != ReminderSheetBottomElement.none) {
      FocusScope.of(context).unfocus();
      gLogger.i("Bottom element changed, un-focusing");
    }

    return AnimatedSize(
      duration: Duration(milliseconds: 300),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutQuad,
        switchOutCurve: Curves.easeInQuad,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                    parent: animation,
                    curve: Interval(0.0, 0.8, curve: Curves.easeOutQuad))),
            child: child,
          );
        },
        child: () {
          switch (element) {
            case ReminderSheetBottomElement.none:
              return SizedBox.shrink(
                key: UniqueKey(),
              );
            case ReminderSheetBottomElement.snoozeOptions:
              gLogger.i("Displaying snooze options");
              return ReminderSnoozeOptionsWidget(
                key: UniqueKey(),
              );
            case ReminderSheetBottomElement.recurrenceOptions:
              gLogger.i("Displaying recurrence options");
              return ReminderRecurrenceOptionsWidget(
                key: UniqueKey(),
              );
          }
        }(),
      ),
    );
  }
}
