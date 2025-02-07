import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/utils/datetime_methods.dart';
import '../../../../settings/presentation/providers/settings_provider.dart';
import '../../providers/central_widget_provider.dart';
import '../../providers/sheet_reminder_notifier.dart';

class ReminderSnoozeOptionsWidget extends ConsumerWidget {
  const ReminderSnoozeOptionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserSettingsNotifier settings =
        ref.watch(userSettingsProvider.notifier);

    final List<Duration> repeatIntervalDurations = <Duration>[
      settings.autoSnoozeOption1,
      settings.autoSnoozeOption2,
      settings.autoSnoozeOption3,
      settings.autoSnoozeOption4,
      settings.autoSnoozeOption5,
      settings.autoSnoozeOption6,
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: GridView.count(
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        crossAxisCount: 3,
        shrinkWrap: true,
        childAspectRatio: 1.5,
        children: <Widget>[
          for (final Duration dur in repeatIntervalDurations)
            intervalEditButton(dur, context, ref),
        ],
      ),
    );
  }

  Widget intervalEditButton(
    Duration duration,
    BuildContext context,
    WidgetRef ref,
  ) {
    final Duration? snoozeInterval =
        ref.read(sheetReminderNotifier).autoSnoozeInterval;
    final bool isPickedDuration = duration == snoozeInterval;
    return ElevatedButton(
      onPressed: () {
        ref.read(sheetReminderNotifier).updateAutoSnoozeInterval(duration);
        ref.read(centralWidgetNotifierProvider.notifier).reset();
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(4),
        surfaceTintColor: Colors.transparent,
        shape: const BeveledRectangleBorder(),
        backgroundColor: isPickedDuration
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Text(
        getFormattedDurationForTimeEditButton(duration),
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: isPickedDuration
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.onSecondaryContainer,
            ),
      ),
    );
  }
}
