import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/constants/const_strings.dart';
import '../../../../core/models/recurring_interval/recurring_interval.dart';
import '../../../../core/models/reminder_model/reminder_model.dart';
import '../../../../shared/widgets/snack_bar/custom_snack_bar.dart';
import '../../../archives/presentation/providers/archives_provider.dart';
import '../../../home/presentation/providers/reminders_provider.dart';
import '../providers/sheet_reminder_notifier.dart';

class BottomButtons extends ConsumerWidget {
  const BottomButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        spacing: 8,
        children: <Widget>[
          Expanded(
            child: _closeButton(context),
          ),
          const Expanded(flex: 3, child: SaveButton()),
        ],
      ),
    );
  }

  Widget _closeButton(BuildContext context) {
    return IconButton.filled(
      icon: const Icon(Icons.close),
      onPressed: () {
        Navigator.of(context).pop();
      },
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

class SaveButton extends ConsumerWidget {
  const SaveButton({super.key});

  Future<void> saveReminder(BuildContext context, WidgetRef ref) async {
    final ReminderModel reminder =
        ref.read(sheetReminderNotifier).constructReminder();

    if (reminder.title == '') {
      AppUtils.showToast(
        msg: 'Enter a title!',
        style: ToastificationStyle.simple,
      );
      return;
    }
    if (reminder.dateTime.isBefore(DateTime.now())) {
      AppUtils.showToast(
        msg: "Can't remind you in the past!",
        style: ToastificationStyle.simple,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SheetReminderNotifier reminder = ref.watch(sheetReminderNotifier);

    final bool forAllCondition = reminder.id != null &&
        reminder.id != newReminderID &&
        reminder.recurringInterval != RecurringInterval.none &&
        !reminder.dateTime.isAtSameMomentAs(reminder.baseDateTime);

    return Row(
      children: <Widget>[
        Expanded(
          child: ElevatedButton(
            onPressed: () => saveReminder(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              padding: EdgeInsets.zero,
              surfaceTintColor: Colors.transparent,
              shape: forAllCondition
                  ? const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.horizontal(left: Radius.circular(18)),
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
        ),
        if (forAllCondition)
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ref.read(sheetReminderNotifier.notifier).refreshBaseDateTime();
                saveReminder(context, ref);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                surfaceTintColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.horizontal(right: Radius.circular(18)),
                ),
              ),
              child: Text(
                'For All',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}
