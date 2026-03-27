import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../reminder/data/models/reminder_base.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/models/sheet_reminder_form.dart';
import '../providers/sheet_reminder_provider.dart';
import '../widgets/bottom_buttons.dart';
import '../widgets/central_section.dart';
import '../widgets/reminder_sheet_top_buttons.dart';
import '../widgets/title_field.dart';

void showReminderSheet(
  BuildContext context, {
  ReminderBase? reminder,
  Duration? customDuration,
  bool isNoRush = false,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => ProviderScope(
      overrides: [
        sheetReminderProvider.overrideWithBuild((ref, notifier) {
          final settings = ref.read(userSettingsProvider);
          return switch (reminder) {
            ReminderBase() => SheetReminderForm.fromReminder(reminder),
            null => SheetReminderForm.initial(
              leadDuration: customDuration ?? settings.defaultLeadDuration,
              defaultAutoSnoozeDuration: settings.defaultAutoSnoozeDuration,
              isNoRush: isNoRush,
            ),
          };
        }),
      ],
      child: const ReminderSheet(),
    ),
  );
}

class ReminderSheet extends ConsumerWidget {
  const ReminderSheet({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final double keyboardInsets = MediaQuery.of(context).viewInsets.bottom;
    final DateTime dateTime = ref.watch(
      sheetReminderProvider.select((SheetReminderForm p) => p.dateTime),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 500 + keyboardInsets),
      child: SingleChildScrollView(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(bottom: 0 + keyboardInsets),
          child: _buildBody(dateTime, theme),
        ),
      ),
    );
  }

  Widget _buildBody(DateTime dateTime, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const ReminderSheetTopButtons(),
        AnimatedContainer(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            color: dateTime.isBefore(DateTime.now())
                ? theme.colorScheme.errorContainer
                : theme.colorScheme.surfaceContainer,
          ),
          duration: const Duration(milliseconds: 500),
          child: const Column(
            children: <Widget>[TitleField(), CentralSection(), BottomButtons()],
          ),
        ),
      ],
    );
  }
}
