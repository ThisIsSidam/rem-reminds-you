import 'package:Rem/feature/settings/presentation/providers/settings_provider.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../shared/widgets/hm_duration_picker.dart';

class DefaultAutoSnoozeDurationModal extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSelectedDuration =
        ref.watch(userSettingsProvider).defaultAutoSnoozeDuration;
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Default Auto Snooze Duration",
                style: Theme.of(context).textTheme.titleMedium),
            Divider(),
            SizedBox(height: 10),
            dateTimeWidget(context, currentSelectedDuration),
            HMDurationPicker(onDurationChange: (dur) {
              ref.read(userSettingsProvider).defaultAutoSnoozeDuration = dur;
            }),
          ],
        ));
  }

  Widget dateTimeWidget(BuildContext context, Duration dur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Theme.of(context).colorScheme.primaryContainer),
          padding: EdgeInsets.all(10),
          child: Center(
              child: Text(
                  'Every ${dur.pretty(tersity: DurationTersity.minute)}',
                  style: Theme.of(context).textTheme.titleMedium))),
    );
  }
}
