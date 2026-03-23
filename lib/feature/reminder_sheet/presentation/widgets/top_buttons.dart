import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/models/recurrence_rule.dart';
import '../../../../core/extensions/context_ext.dart';
import '../providers/central_widget_provider.dart';
import '../providers/sheet_reminder_notifier.dart';

class TopButtons extends ConsumerWidget {
  const TopButtons({super.key});

  Future<void> deleteReminder(
    int id,
    BuildContext context,
    WidgetRef ref,
  ) async {
    void finalDelete({bool deleteAllRecurring = false}) {
      ref.read(sheetReminderNotifier.notifier).deleteReminder(id);
      Navigator.pop(context);
    }

    final RecurrenceRule recurrenceRule = ref
        .read(sheetReminderNotifier)
        .recurrenceRule;

    if (!recurrenceRule.isNone && context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return _RecurringReminderDeletionDialog(finalDelete: finalDelete);
        },
      );
    } else {
      finalDelete();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? id = ref.watch(
      sheetReminderNotifier.select((SheetReminderNotifier p) => p.id),
    );
    final bool noRush = ref.watch(
      sheetReminderNotifier.select((SheetReminderNotifier p) => p.noRush),
    );
    final CentralElement centralElement = ref.watch(centralWidgetProvider);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (id != null) ...<Widget>[
            _buildButton(
              context: context,
              icon: Icons.delete,
              active: true,
              fillColor: Theme.of(context).colorScheme.errorContainer,
              onTap: () => deleteReminder(id, context, ref),
            ),
            const Spacer(),
          ],
          if (!noRush) ...<Widget>[
            _buildButton(
              context: context,
              icon: Icons.snooze,
              active: centralElement == CentralElement.snoozeOptions,
              onTap: () {
                ref
                    .read(centralWidgetProvider.notifier)
                    .switchTo(CentralElement.snoozeOptions);
              },
            ),
            _buildButton(
              context: context,
              icon: Icons.event_repeat,
              active: centralElement == CentralElement.recurrenceOptions,
              onTap: () {
                ref
                    .read(centralWidgetProvider.notifier)
                    .switchTo(CentralElement.recurrenceOptions);
              },
            ),
          ],
          _buildButton(
            context: context,
            icon: Icons.event_busy,
            active: noRush,
            onTap: () {
              ref.read(sheetReminderNotifier.notifier).toggleNoRushSwitch();
            },
          ),
        ],
      ),
    );
  }

  IconButton _buildButton({
    required BuildContext context,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    Color? fillColor,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return IconButton.filled(
      constraints: const BoxConstraints(maxWidth: 64),
      icon: Icon(
        icon,
        size: 28,
        color: active
            ? colorScheme.onPrimaryContainer
            : colorScheme.primaryContainer,
      ),
      style: IconButton.styleFrom(
        backgroundColor: active
            ? fillColor ?? colorScheme.primaryContainer
            : colorScheme.onPrimaryContainer,
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      onPressed: onTap,
    );
  }
}

class _RecurringReminderDeletionDialog extends ConsumerWidget {
  const _RecurringReminderDeletionDialog({required this.finalDelete});

  final void Function({bool deleteAllRecurring}) finalDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      elevation: 5,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Theme.of(context).cardColor,
      title: Text(
        context.local.sheetRecurringDialogTitle,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: Text(
        // ignore: lines_longer_than_80_chars
        context.local.sheetRecurringDialogContent,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text(
            context.local.sheetCancel,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        TextButton(
          onPressed: () {
            finalDelete(deleteAllRecurring: true);
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text(
            context.local.sheetDelete,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}
