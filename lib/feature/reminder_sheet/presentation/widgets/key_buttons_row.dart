import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../core/constants/const_strings.dart';
import '../../../../core/models/recurring_interval/recurring_interval.dart';
import '../../../../core/models/recurring_reminder/recurring_reminder.dart';
import '../../../../core/models/reminder_model/reminder_model.dart';
import '../../../archives/presentation/providers/archives_provider.dart';
import '../../../home/presentation/providers/reminders_provider.dart';
import '../providers/central_widget_provider.dart';
import '../providers/sheet_reminder_notifier.dart';

class KeyButtonsRow extends ConsumerWidget {
  const KeyButtonsRow({
    super.key,
  });

  Future<void> saveReminder(BuildContext context, WidgetRef ref) async {
    final ReminderModel reminder =
        ref.read(sheetReminderNotifier).constructReminder();

    if (reminder.title == 'No Title') {
      await Fluttertoast.showToast(msg: 'Enter a title!');
      return;
    }
    if (reminder.dateTime.isBefore(DateTime.now())) {
      await Fluttertoast.showToast(
        msg: "Time machine is broke. Can't remind you in the past!",
      );
      return;
    }

    if (await ref.read(archivesProvider).isInArchives(reminder.id)) {
      await ref.read(remindersProvider).retrieveFromArchives(reminder.id);
    } else {
      await ref.read(remindersProvider).saveReminder(reminder);
    }

    if (!context.mounted) return;
    Navigator.pop(context);
  }

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
          Row(
            spacing: 4,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildButton(
                context: context,
                icon: Icons.close,
                active: true,
                onTap: () => Navigator.pop(context),
              ),
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
              _buildSaveButton(context, ref),
            ],
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
        size: 24,
        color: active
            ? colorScheme.onPrimaryContainer
            : colorScheme.primaryContainer,
      ),
      style: IconButton.styleFrom(
        backgroundColor: active
            ? fillColor ?? colorScheme.primaryContainer
            : colorScheme.onPrimaryContainer,
        padding: const EdgeInsets.all(8),
        shape: const CircleBorder(),
      ),
      onPressed: onTap,
    );
  }

  Widget _buildSaveButton(BuildContext context, WidgetRef ref) {
    final SheetReminderNotifier reminder = ref.read(sheetReminderNotifier);

    final bool forAllCondition = reminder.id != newReminderID &&
        reminder is RecurringReminderModel &&
        reminder.recurringInterval != RecurringInterval.none &&
        !reminder.dateTime.isAtSameMomentAs(reminder.baseDateTime);

    return Row(
      children: <Widget>[
        ElevatedButton(
          onPressed: () => saveReminder(context, ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            surfaceTintColor: Colors.transparent,
            shape: forAllCondition
                ? const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.horizontal(left: Radius.circular(25)),
                  )
                : null,
          ),
          child: Text(
            'Save',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
        ),
        if (forAllCondition)
          ElevatedButton(
            onPressed: () {
              saveReminder(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              surfaceTintColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.horizontal(right: Radius.circular(25)),
              ),
            ),
            child: Text(
              'For All',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
          ),
      ],
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
