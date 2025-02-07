import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../shared/widgets/hm_duration_picker.dart';
import '../../../providers/settings_provider.dart';

class DefaultAutoSnoozeDurationModal extends ConsumerWidget {
  const DefaultAutoSnoozeDurationModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Duration currentSelectedDuration =
        ref.watch(userSettingsProvider).defaultAutoSnoozeDuration;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Default Auto Snooze Duration',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(),
          const SizedBox(height: 10),
          dateTimeWidget(context, currentSelectedDuration),
          HMDurationPicker(
            onDurationChange: (Duration dur) {
              ref.read(userSettingsProvider).defaultAutoSnoozeDuration = dur;
            },
          ),
        ],
      ),
    );
  }

  Widget dateTimeWidget(BuildContext context, Duration dur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Text(
            'Every ${dur.pretty(tersity: DurationTersity.minute)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
