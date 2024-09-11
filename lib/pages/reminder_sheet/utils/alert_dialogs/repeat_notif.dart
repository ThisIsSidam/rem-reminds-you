import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/pages/reminder_sheet/utils/base_versions/alert_dialog_base.dart';
import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:Rem/utils/datetime_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RepeatNotifDialog extends ConsumerWidget {
  RepeatNotifDialog({super.key});

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
      title: "Repeat Notification",
      tooltipMsg: "A reminder's notification are repeated at a certain interval until you mark the reminder as done.",
      content: SizedBox(
        height: 175,
        width: 375,
        child: getButtonsGrid(context, ref)
      ),
    );
  }

  Widget getButtonsGrid(BuildContext context, WidgetRef ref) {
    return GridView.count(
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      crossAxisCount: 3,
      shrinkWrap: true,
      childAspectRatio: 1.5,
      children: [
        for (var dur in repeatIntervalDurations)
          intervalEditButton(dur, context, ref),
      ],
    );
  }

  Widget intervalEditButton(Duration duration, BuildContext context, WidgetRef ref) {

    final reminder = ref.read(reminderNotifierProvider);
    bool isPickedDuration = duration == reminder.notifRepeatInterval;
    return SizedBox(
      height: 60,
      width: 150,
      child: ElevatedButton(
        onPressed: () {
          reminder.notifRepeatInterval = duration;
          ref.read(reminderNotifierProvider.notifier).updateReminder(reminder);
          Navigator.pop(context);
        },
        style: isPickedDuration
        ? Theme.of(context).elevatedButtonTheme.style!.copyWith(
          backgroundColor: WidgetStatePropertyAll(Theme.of(context).primaryColor)
        )
        : Theme.of(context).elevatedButtonTheme.style, 
        child: Text(
          getFormattedDurationForTimeEditButton(duration),
          style: Theme.of(context).textTheme.bodyLarge,
        )
      ),
    );
  }
}