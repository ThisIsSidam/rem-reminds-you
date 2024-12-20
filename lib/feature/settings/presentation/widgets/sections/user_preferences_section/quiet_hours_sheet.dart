import 'package:Rem/feature/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum SelectedTime { start, end }

class QuietHoursSheet extends HookWidget {
  QuietHoursSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<SelectedTime> selectedTimeNotifier =
        ValueNotifier(SelectedTime.start);

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: ValueListenableBuilder(
            valueListenable: selectedTimeNotifier,
            builder: (context, selectedTime, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Quiet Hours",
                      style: Theme.of(context).textTheme.titleMedium),
                  Divider(),
                  _buildTimeButtonsRow(selectedTime, selectedTimeNotifier),
                  const SizedBox(height: 40),
                  _buildTimePicker(selectedTime),
                  const SizedBox(height: 40),
                ],
              );
            }));
  }

  Consumer _buildTimeButtonsRow(
      SelectedTime timeType, ValueNotifier<SelectedTime> selectedTime) {
    return Consumer(
      builder: (context, ref, child) {
        final (DateTime, DateTime) quietHours = ref.watch(userSettingsProvider
            .select((p) => (p.quietHoursStartTime, p.quietHoursEndTime)));
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: timeType != SelectedTime.start
                    ? () {
                        selectedTime.value = SelectedTime.start;
                      }
                    : null,
                child: Text(
                  '${quietHours.$1.hour.toString().padLeft(2, '0')}:${quietHours.$1.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: timeType == SelectedTime.start
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.tertiaryContainer,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(12),
                      right: Radius.zero,
                    ),
                  ),
                  disabledBackgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
            ),
            DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child:
                      Text(':', style: Theme.of(context).textTheme.titleLarge),
                )),
            Expanded(
              child: ElevatedButton(
                onPressed: selectedTime.value != SelectedTime.end
                    ? () {
                        selectedTime.value = SelectedTime.end;
                      }
                    : null,
                child: Text(
                  '${quietHours.$2.hour.toString().padLeft(2, '0')}:${quietHours.$2.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: timeType == SelectedTime.end
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.tertiaryContainer,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.zero,
                      right: Radius.circular(12),
                    ),
                  ),
                  disabledBackgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
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
      child: Consumer(builder: (context, ref, child) {
        final settings = ref.watch(userSettingsProvider.notifier);
        return CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          use24hFormat: true,
          initialDateTime: settings.quietHoursStartTime,
          onDateTimeChanged: (dt) {
            if (selectedTime == SelectedTime.start) {
              settings.quietHoursStartTime = dt;
            } else {
              settings.quietHoursEndTime = dt;
            }
          },
        );
      }),
    );
  }
}
