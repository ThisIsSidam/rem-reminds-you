import 'package:Rem/feature/reminder_screen/presentation/providers/central_widget_provider.dart';
import 'package:Rem/feature/reminder_screen/presentation/providers/sheet_reminder_notifier.dart';
import 'package:Rem/feature/reminder_screen/presentation/widgets/bottom_elements/recurrence_options.dart';
import 'package:Rem/feature/reminder_screen/presentation/widgets/bottom_elements/snooze_options.dart';
import 'package:Rem/feature/reminder_screen/presentation/widgets/time_button.dart';
import 'package:Rem/shared/utils/datetime_methods.dart';
import 'package:Rem/shared/utils/logger/global_logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../settings/presentation/providers/settings_provider.dart';

class CentralSection extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateTime = ref.watch(sheetReminderNotifier.select((p) => p.dateTime));
    final noRush = ref.watch(sheetReminderNotifier.select((p) => p.noRush));
    final bottomElement = ref.watch(centralWidgetNotifierProvider);
    final bottomElementNotifier =
        ref.read(centralWidgetNotifierProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!noRush)
          TextButton(
            onPressed: () {
              if (bottomElement != CentralElement.dateTimeGrid) {
                bottomElementNotifier
                    .switchTo(CentralElement.dateTimeGrid);
              } else {
                bottomElementNotifier
                    .switchTo(CentralElement.timePicker);
              }
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
        CentralWidget(),
      ],
    );
  }
}

class CentralWidget extends ConsumerWidget {
  const CentralWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final element = ref.watch(centralWidgetNotifierProvider);
    final settings = ref.watch(userSettingsProvider);
    final dateTime = ref.watch(sheetReminderNotifier).dateTime;
    // FocusScope.of(context).unfocus();
    if (element != CentralElement.dateTimeGrid) {
      gLogger.i("Bottom element changed, un-focusing");
    }
    return AnimatedSize(
      duration: Duration(milliseconds: 300),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutQuad,
        switchOutCurve: Curves.easeInQuad,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                    parent: animation,
                    curve: Interval(0.0, 0.8, curve: Curves.easeOutQuad))),
            child: child,
          );
        },
        child: () {
          switch (element) {
            case CentralElement.noRush:
              return SizedBox.shrink();
            case CentralElement.dateTimeGrid:
              return _buildTimeButtonsGrid(settings);
            case CentralElement.timePicker:
              return _buildTimePicker(
                ref,
                dateTime,
              );
            case CentralElement.snoozeOptions:
              gLogger.i("Displaying snooze options");
              return ReminderSnoozeOptionsWidget(
                key: UniqueKey(),
              );
            case CentralElement.recurrenceOptions:
              gLogger.i("Displaying recurrence options");
              return ReminderRecurrenceOptionsWidget(
                key: UniqueKey(),
              );
          }
        }(),
      ),
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
      borderRadius: BorderRadius.circular(24),
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
