import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../providers/settings_provider.dart';

enum SelectedTime { none, start, end }

class QuietHoursSheet extends HookWidget {
  const QuietHoursSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<SelectedTime> selectedTimeNotifier =
        ValueNotifier<SelectedTime>(SelectedTime.none);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: ValueListenableBuilder<SelectedTime>(
          valueListenable: selectedTimeNotifier,
          builder:
              (BuildContext context, SelectedTime selectedTime, Widget? child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Quiet Hours',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(),
                _buildTimeButtonsRow(selectedTime, selectedTimeNotifier),
                const SizedBox(height: 40),
                if (selectedTime != SelectedTime.none) ...<Widget>[
                  _buildTimePicker(selectedTime),
                  const SizedBox(height: 40),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Consumer _buildTimeButtonsRow(
    SelectedTime timeType,
    ValueNotifier<SelectedTime> selectedTime,
  ) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final (TimeOfDay, TimeOfDay) quietHours = ref.watch(
          userSettingsProvider.select(
            (UserSettingsNotifier p) =>
                (p.quietHoursStartTime, p.quietHoursEndTime),
          ),
        );
        return Row(
          children: <Widget>[
            Expanded(
              child: SizedBox(
                height: 75,
                child: ElevatedButton(
                  onPressed: timeType != SelectedTime.start
                      ? () {
                          selectedTime.value = SelectedTime.start;
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.tertiaryContainer,
                    surfaceTintColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(12),
                      ),
                    ),
                    disabledBackgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Text(
                    // ignore: lines_longer_than_80_chars
                    '${quietHours.$1.hour.toString().padLeft(2, '0')}:${quietHours.$1.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: timeType == SelectedTime.start
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(':', style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 75,
                child: ElevatedButton(
                  onPressed: selectedTime.value != SelectedTime.end
                      ? () {
                          selectedTime.value = SelectedTime.end;
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.tertiaryContainer,
                    surfaceTintColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(12),
                      ),
                    ),
                    disabledBackgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Text(
                    // ignore: lines_longer_than_80_chars
                    '${quietHours.$2.hour.toString().padLeft(2, '0')}:${quietHours.$2.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: timeType == SelectedTime.end
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  SizedBox _buildTimePicker(SelectedTime selectedTime) {
    return SizedBox(
      height: 125,
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final UserSettingsNotifier settings = ref.watch(userSettingsProvider);
          return CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            use24hFormat: true,
            onDateTimeChanged: (DateTime dt) {
              if (selectedTime == SelectedTime.start) {
                settings.setQuietHoursStartTime(
                  TimeOfDay(
                    hour: dt.hour,
                    minute: dt.minute,
                  ),
                );
              } else {
                settings.setQuietHoursEndTime(
                  TimeOfDay(
                    hour: dt.hour,
                    minute: dt.minute,
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
