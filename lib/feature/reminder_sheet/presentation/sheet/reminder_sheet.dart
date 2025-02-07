import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sheet_reminder_notifier.dart';
import '../widgets/central_section.dart';
import '../widgets/key_buttons_row.dart';
import '../widgets/title_field.dart';

class ReminderSheet extends ConsumerWidget {
  const ReminderSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final double keyboardInsets = MediaQuery.of(context).viewInsets.bottom;
    final DateTime dateTime = ref.watch(
      sheetReminderNotifier.select((SheetReminderNotifier p) => p.dateTime),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 500 + keyboardInsets,
      ),
      child: SingleChildScrollView(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            color: dateTime.isBefore(DateTime.now())
                ? theme.colorScheme.errorContainer
                : null,
          ),
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + keyboardInsets),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TitleField(),
              CentralSection(),
              const KeyButtonsRow(),
            ],
          ),
        ),
      ),
    );
  }
}
