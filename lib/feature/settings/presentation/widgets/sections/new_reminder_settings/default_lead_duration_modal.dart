import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/datetime_ext.dart';
import '../../../../../../shared/widgets/hm_duration_picker.dart';
import '../../../providers/settings_provider.dart';

class DefaultLeadDurationModal extends ConsumerWidget {
  const DefaultLeadDurationModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Duration currentSelectedDuration =
        ref.watch(userSettingsProvider).defaultLeadDuration;
    final DateTime dateTime = DateTime.now().add(currentSelectedDuration);
    final String dateTimeString = dateTime.friendly;
    final String diffString = dateTime.prettyDuration;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Default Lead Duration',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(),
          const SizedBox(height: 10),
          dateTimeWidget(context, dateTimeString, diffString),
          HMDurationPicker(
            onDurationChange: (Duration dur) {
              ref.read(userSettingsProvider).defaultLeadDuration = dur;
            },
          ),
        ],
      ),
    );
  }

  Widget dateTimeWidget(
    BuildContext context,
    String dateTimeString,
    String diffString,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            dateTimeString,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            diffString,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
