import 'package:Rem/feature/reminder_screen/presentation/providers/sheet_reminder_notifier.dart';
import 'package:Rem/feature/reminder_screen/presentation/widgets/time_button.dart';
import 'package:Rem/shared/utils/datetime_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../settings/presentation/providers/settings_provider.dart';

class DateTimeSection extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showTimePickerNotifier = useValueNotifier<bool>(false);

    final dateTime = ref.watch(sheetReminderNotifier.select((p) => p.dateTime));
    final noRush = ref.watch(sheetReminderNotifier.select((p) => p.noRush));
    final settings = ref.watch(userSettingsProvider);

    useEffect(() {
      if (noRush) showTimePickerNotifier.value = true;
      return null;
    }, [noRush]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!noRush)
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
              secondChild: _buildHiddenSection(context, ref, dateTime, noRush),
              crossFadeState:
                  show ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              sizeCurve: Curves.easeInOut,
            );
          },
        )
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
          ...setDateTimes.map(
            (dateTime) => TimeSetButton(dateTime: dateTime),
          ),
          ...editDurations.map(
            (duration) => TimeEditButton(duration: duration),
          ),
        ],
      ),
    );
  }

  Widget _buildHiddenSection(
      BuildContext context, WidgetRef ref, DateTime dateTime, bool noRush) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: noRush
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text('No Rush'),
              trailing: Switch(
                value: noRush,
                onChanged: (bool val) {
                  ref.read(sheetReminderNotifier).toggleNoRushSwitch(val);
                },
              ),
            ),
          ),
        ),
        if (!noRush) _buildTimePicker(ref, dateTime),
      ],
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
              ref.read(sheetReminderNotifier).updateDateTime(dt),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
