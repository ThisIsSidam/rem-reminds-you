import 'package:Rem/shared/utils/datetime_methods.dart';
import 'package:Rem/shared/widgets/hm_duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/settings_provider.dart';

class DefaultLeadDurationModal extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Duration currentSelectedDuration =
        ref.watch(userSettingsProvider).defaultLeadDuration;
    DateTime dateTime = DateTime.now().add(currentSelectedDuration);
    String dateTimeString = getFormattedDateTime(dateTime);
    String diffString = getPrettyDurationFromDateTime(dateTime);

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Default Lead Duration",
                style: Theme.of(context).textTheme.titleMedium),
            Divider(),
            SizedBox(height: 10),
            dateTimeWidget(context, dateTimeString, diffString),
            HMDurationPicker(onDurationChange: (dur) {
              ref.read(userSettingsProvider).defaultLeadDuration = dur;
            }),
          ],
        ));
  }

  Widget dateTimeWidget(
      BuildContext context, String dateTimeString, String diffString) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(dateTimeString,
                style: Theme.of(context).textTheme.titleMedium),
            Text(diffString,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: Colors.white, fontSize: 12))
          ],
        ));
  }
}
