import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:Rem/screens/reminder_sheet/widgets/time_button.dart';
import 'package:Rem/utils/datetime_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../provider/settings_provider.dart';

class DateTimeField extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showTimePickerNotifier = useValueNotifier<bool>(false);

    final dateTime =
        ref.watch(reminderNotifierProvider.select((p) => p.dateTime));
    final settings = ref.watch(userSettingsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {
            showTimePickerNotifier.value = !showTimePickerNotifier.value;
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                getFormattedDateTime(dateTime),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: dateTime.isBefore(DateTime.now())
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
              ),
              const SizedBox(
                width: 24,
              ),
              Flexible(
                child: Text(
                  dateTime.isBefore(DateTime.now())
                      ? '${getPrettyDurationFromDateTime(dateTime)} ago'
                          .replaceFirst('-', '')
                      : 'in ${getPrettyDurationFromDateTime(dateTime)}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: dateTime.isBefore(DateTime.now())
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        ValueListenableBuilder(
            valueListenable: showTimePickerNotifier,
            builder: (context, bool show, _) {
              return AnimatedCrossFade(
                duration: Duration(milliseconds: 300),
                firstChild: _buildTimeButtonsGrid(settings),
                secondChild: _buildTimePicker(ref, dateTime),
                crossFadeState:
                    show ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                sizeCurve: Curves.easeInOut,
              );
            })
      ],
    );
  }

  Widget _buildTimeButtonsGrid(UserSettingsNotifier settings) {
    // Get the preset times from settings
    final setDateTimes = [
      settings.quickTimeSetOption1,
      settings.quickTimeSetOption2,
      settings.quickTimeSetOption3,
      settings.quickTimeSetOption4,
    ];

    // Get the duration options from settings
    final editDurations = [
      settings.quickTimeEditOption1,
      settings.quickTimeEditOption2,
      settings.quickTimeEditOption3,
      settings.quickTimeEditOption4,
      settings.quickTimeEditOption5,
      settings.quickTimeEditOption6,
      settings.quickTimeEditOption7,
      settings.quickTimeEditOption8,
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: GridView.count(
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        crossAxisCount: 4,
        shrinkWrap: true,
        childAspectRatio: 1.5,
        children: [
          ...setDateTimes.map((dateTime) => TimeSetButton(dateTime: dateTime)),
          ...editDurations
              .map((duration) => TimeEditButton(duration: duration)),
        ],
      ),
    );
  }

  Widget _buildTimePicker(WidgetRef ref, DateTime dateTime) {
    return SizedBox(
      height: 175,
      child: CupertinoTheme(
        data: const CupertinoThemeData(brightness: Brightness.dark),
        child: CupertinoDatePicker(
          initialDateTime: dateTime,
          itemExtent: 75,
          onDateTimeChanged: (DateTime dt) =>
              ref.read(reminderNotifierProvider).updateDateTime(dt),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
