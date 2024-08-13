import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/pages/reminder_page/utils/base_versions/alert_dialog_base.dart';
import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/utils/other_utils/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReminderRecurrenceDialog extends ConsumerWidget {
  ReminderRecurrenceDialog({super.key});

  final List<Duration> repeatIntervalDurations = List.generate(6, (index) {
    final dur = UserDB.getSetting(SettingsOptionMethods.fromInt(index + 15));;
    if (!(dur is Duration)) 
    {
      print("[repeatIntervals] Duration not received | $dur");
    }
    return dur;
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return AlertDialogBase(
      title: "Recurrence Interval",
      tooltipMsg: "Reminder is repeat on either daily or weekly basis. Monthly and More are coming soon.",
      content: SizedBox(
        height: 250,
        width: 375,
        child: getButtonsGrid(context, ref)
      ),
    );
  }

  Widget getButtonsGrid(BuildContext context, WidgetRef ref) {
    return GridView.count(
      mainAxisSpacing: 8,
      crossAxisSpacing: 8
      ,
      crossAxisCount: 2,
      shrinkWrap: true,
      childAspectRatio: 1.5,
      children: [
        intervalButton(RecurringInterval.none, context, ref),
        intervalButton(RecurringInterval.daily, context, ref),
        intervalButton(RecurringInterval.weekly, context, ref),
        intervalButton(RecurringInterval.custom, context, ref),
      ],
    );
  }

  Widget intervalButton(RecurringInterval interval, BuildContext context, WidgetRef ref) {
    final reminder = ref.read(reminderNotifierProvider);
    print("interval: ${reminder.mixinRecurringInterval}");
    bool isPickedOption = interval == reminder.recurringInterval;

    return SizedBox(
      height: 75,
      width: 150,
      child: ElevatedButton(
        onPressed: () {
          if (interval == RecurringInterval.custom)
          {
            showFlutterToast("Coming soon!");
            return;
          }
          reminder.recurringInterval = interval;
          ref.read(reminderNotifierProvider.notifier).updateReminder(reminder);
          Navigator.pop(context);
        }, 
        style: isPickedOption
        ? Theme.of(context).elevatedButtonTheme.style!.copyWith(
          backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor)
        )
        : Theme.of(context).elevatedButtonTheme.style, 
        child: Text(
          RecurringIntervalExtension.getDisplayName(interval),
          style: Theme.of(context).textTheme.bodyLarge
        ),
      ),
    );
  }
}