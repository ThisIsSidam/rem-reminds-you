import 'package:Rem/core/constants/const_strings.dart';
import 'package:Rem/core/models/basic_reminder_model.dart';
import 'package:Rem/feature/home/presentation/providers/reminders_provider.dart';
import 'package:Rem/feature/reminder_screen/presentation/providers/central_widget_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../core/enums/recurring_interval.dart';
import '../../../../core/models/recurring_reminder/recurring_reminder_model.dart';
import '../../../archives/presentation/providers/archives_provider.dart';
import '../providers/sheet_reminder_notifier.dart';

class KeyButtonsRow extends ConsumerWidget {
  const KeyButtonsRow({
    super.key,
  });

  void saveReminder(BuildContext context, WidgetRef ref) async {
    final BasicReminderModel reminder =
        ref.read(sheetReminderNotifier).constructReminder();

    if (reminder.title == "No Title") {
      Fluttertoast.showToast(msg: "Enter a title!");
      return;
    }
    if (reminder.dateTime.isBefore(DateTime.now())) {
      Fluttertoast.showToast(
          msg: "Time machine is broke. Can't remind you in the past!");
      return;
    }

    if ((await ref.read(archivesProvider).isInArchives(reminder.id))) {
      ref.read(remindersProvider).retrieveFromArchives(reminder.id);
    } else {
      ref.read(remindersProvider).saveReminder(reminder);
    }
    Navigator.pop(context);
  }

  void deleteReminder(
    int id,
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (await ref.read(archivesProvider).isInArchives(id)) {
      ref.read(archivesProvider).deleteArchivedReminder(id);
      return;
    }

    void finalDelete({deleteAllRecurring = false}) {
      ref.read(remindersProvider).deleteReminder(
            id,
          );
      Navigator.pop(context);
    }

    final recurringInterval = ref.read(sheetReminderNotifier).recurringInterval;

    if (recurringInterval != RecurringInterval.none) {
      showDialog(
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
    final id = ref.watch(sheetReminderNotifier.select((p) => p.id));
    final noRush = ref.watch(sheetReminderNotifier.select((p) => p.noRush));
    final centralElement = ref.watch(centralWidgetNotifierProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (id != null) ...<Widget>[
            _buildButton(
              context: context,
              icon: Icons.delete,
              active: true,
              fillColor: Theme.of(context).colorScheme.errorContainer,
              onTap: () => deleteReminder(id, context, ref),
            ),
            Spacer(),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(
                context: context,
                icon: Icons.close,
                active: true,
                onTap: () => Navigator.pop(context),
                fillColor: Colors.grey,
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
              _buildSaveButton(context, ref)
            ],
          ),
        ],
      ),
    );
  }

  RawMaterialButton _buildButton({
    required BuildContext context,
    required IconData icon,
    required active,
    required onTap,
    Color? fillColor,
  }) {
    return RawMaterialButton(
      constraints: BoxConstraints(maxWidth: 48),
      child: Icon(icon),
      fillColor: active
          ? fillColor ?? Theme.of(context).colorScheme.primaryContainer
          : Colors.grey,
      onPressed: onTap,
      padding: EdgeInsets.all(8),
      shape: CircleBorder(),
    );
  }

  Widget _buildSaveButton(BuildContext context, WidgetRef ref) {
    final reminder = ref.read(sheetReminderNotifier);

    bool forAllCondition = reminder.id != newReminderID &&
        reminder is RecurringReminderModel &&
        reminder.recurringInterval != RecurringInterval.none &&
        !reminder.dateTime.isAtSameMomentAs(reminder.baseDateTime);

    return Row(
      children: [
        ElevatedButton(
          child: Text(
            "Save",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
          onPressed: () => saveReminder(context, ref),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              surfaceTintColor: Colors.transparent,
              shape: forAllCondition
                  ? RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.horizontal(left: Radius.circular(25)))
                  : null),
        ),
        if (forAllCondition)
          ElevatedButton(
            onPressed: () {
              saveReminder(context, ref);
            },
            child: Text("For All",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer)),
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.horizontal(right: Radius.circular(25)))),
          ),
      ],
    );
  }
}

class _RecurringReminderDeletionDialog extends ConsumerWidget {
  const _RecurringReminderDeletionDialog({required this.finalDelete});

  final Function({bool deleteAllRecurring}) finalDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(sheetReminderNotifier.select((p) => p.id));
    return AlertDialog(
      elevation: 5,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Theme.of(context).cardColor,
      title: Text(
        'Recurring Reminder',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: Text(
        'This is a recurring reminder. Do you really want to delete it? You can also archive it.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [
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
