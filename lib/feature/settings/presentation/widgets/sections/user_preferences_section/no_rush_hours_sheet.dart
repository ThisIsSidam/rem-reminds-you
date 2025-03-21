import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../providers/settings_provider.dart';

enum SelectedTime { start, end }

class NoRushHoursSheet extends HookWidget {
  const NoRushHoursSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<SelectedTime> selectedTimeNotifier =
        ValueNotifier<SelectedTime>(SelectedTime.start);

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
                  'No rush hours',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  child: Text(
                    // ignore: lines_longer_than_80_chars
                    'No rush reminders are shown only within this time range, so that you only get notified when you want to.',
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildTimeButtonsRow(selectedTime, selectedTimeNotifier),
                const SizedBox(height: 40),
                _buildTimePicker(selectedTime),
                const SizedBox(height: 40),
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
        final (TimeOfDay, TimeOfDay) noRushHours = ref.watch(
          userSettingsProvider.select(
            (UserSettingsNotifier p) => (p.noRushStartTime, p.noRushEndTime),
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
                    '${noRushHours.$1.hour.toString().padLeft(2, '0')}:${noRushHours.$1.minute.toString().padLeft(2, '0')}',
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
                    '${noRushHours.$2.hour.toString().padLeft(2, '0')}:${noRushHours.$2.minute.toString().padLeft(2, '0')}',
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
                settings.setNoRushStartTime(
                  TimeOfDay(
                    hour: dt.hour,
                    minute: dt.minute,
                  ),
                );
              } else {
                settings.setNoRushEndTime(
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
