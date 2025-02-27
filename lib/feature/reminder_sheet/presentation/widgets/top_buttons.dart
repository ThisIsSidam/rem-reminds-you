import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/models/recurring_interval/recurring_interval.dart';
import '../../../archives/presentation/providers/archives_provider.dart';
import '../../../home/presentation/providers/reminders_provider.dart';
import '../providers/central_widget_provider.dart';
import '../providers/sheet_reminder_notifier.dart';

class TopButtons extends ConsumerWidget {
  const TopButtons({
    super.key,
  });

  Future<void> deleteReminder(
    int id,
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (await ref.read(archivesProvider).isInArchives(id)) {
      await ref.read(archivesProvider).deleteArchivedReminder(id);
      return;
    }

    void finalDelete({bool deleteAllRecurring = false}) {
      ref.read(remindersProvider).deleteReminder(
            id,
          );
      Navigator.pop(context);
    }

    final RecurringInterval recurringInterval =
        ref.read(sheetReminderNotifier).recurringInterval;

    if (recurringInterval != RecurringInterval.none && context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return _RecurringReminderDeletionDialog(
            finalDelete: finalDelete,
          );
        },
      );
    } else {
      finalDelete();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? id = ref
        .watch(sheetReminderNotifier.select((SheetReminderNotifier p) => p.id));
    final bool noRush = ref.watch(
      sheetReminderNotifier.select((SheetReminderNotifier p) => p.noRush),
    );
    final CentralElement centralElement =
        ref.watch(centralWidgetNotifierProvider);

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
                    .read(centralWidgetNotifierProvider.notifier)
                    .switchTo(CentralElement.snoozeOptions);
              },
            ),
            _buildButton(
              context: context,
              icon: Icons.event_repeat,
              active: centralElement == CentralElement.recurrenceOptions,
              onTap: () {
                ref
                    .read(centralWidgetNotifierProvider.notifier)
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
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
    final int? id = ref
        .watch(sheetReminderNotifier.select((SheetReminderNotifier p) => p.id));
    return AlertDialog(
      elevation: 5,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Theme.of(context).cardColor,
      title: Text(
        'Recurring Reminder',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: Text(
        // ignore: lines_longer_than_80_chars
        'This is a recurring reminder. Do you really want to delete it? You can also archive it.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: <Widget>[
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
            ref.read(remindersProvider).moveToArchive(id!);
            Navigator.of(context).pop(); // Close the dialog
            Navigator.pop(context);
          },
          child: Text(
            'Archive',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        TextButton(
          onPressed: () {
            finalDelete(deleteAllRecurring: true);
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text(
            'Delete',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}
