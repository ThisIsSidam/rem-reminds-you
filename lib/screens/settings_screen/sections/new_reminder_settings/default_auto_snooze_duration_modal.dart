import 'package:Rem/consts/const_colors.dart';
import 'package:Rem/provider/settings_provider.dart';
import 'package:Rem/widgets/duration_picker.dart';
import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DefaultAutoSnoozeDurationModal extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSelectedDuration =
        ref.watch(userSettingsProvider).defaultAutoSnoozeDuration;
    return Container(
        height: 350,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: [
            Text("Default Auto Snooze Duration",
                style: Theme.of(context).textTheme.titleLarge),
            Divider(),
            SizedBox(height: 10),
            dateTimeWidget(context, currentSelectedDuration),
            DurationPickerBase(onDurationChange: (dur) {
              ref.read(userSettingsProvider).defaultAutoSnoozeDuration = dur;
            }),
          ],
        ));
  }

  Widget dateTimeWidget(BuildContext context, Duration dur) {
    return Container(
        width: MediaQuery.sizeOf(context).width * 0.5,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: ConstColors.lightGreyLessOpacity),
        padding: EdgeInsets.all(10),
        child: Center(
            child: Text('Every ${dur.pretty(tersity: DurationTersity.minute)}',
                style: Theme.of(context).textTheme.titleMedium)));
  }
}
