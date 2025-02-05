import 'package:Rem/feature/reminder_sheet/presentation/providers/sheet_reminder_notifier.dart';
import 'package:Rem/feature/reminder_sheet/presentation/widgets/central_section.dart';
import 'package:Rem/feature/reminder_sheet/presentation/widgets/key_buttons_row.dart';
import 'package:Rem/feature/reminder_sheet/presentation/widgets/title_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReminderSheet extends ConsumerWidget {
  const ReminderSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final keyboardInsets = MediaQuery.of(context).viewInsets.bottom;
    final dateTime = ref.watch(sheetReminderNotifier.select((p) => p.dateTime));

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 500 + keyboardInsets,
      ),
      child: SingleChildScrollView(
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            color: dateTime.isBefore(DateTime.now())
                ? theme.colorScheme.errorContainer
                : null,
          ),
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + keyboardInsets),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TitleField(),
              CentralSection(),
              KeyButtonsRow(),
            ],
          ),
        ),
      ),
    );
  }
}
