import 'package:Rem/feature/reminder_sheet/presentation/providers/central_widget_provider.dart';
import 'package:Rem/feature/reminder_sheet/presentation/providers/sheet_reminder_notifier.dart';
import 'package:Rem/feature/reminder_sheet/presentation/widgets/bottom_elements/recurrence_options.dart';
import 'package:Rem/feature/reminder_sheet/presentation/widgets/bottom_elements/snooze_options.dart';
import 'package:Rem/feature/reminder_sheet/presentation/widgets/time_button.dart';
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
    final centralElement = ref.watch(centralWidgetNotifierProvider);
    final centralElementNotififer =
        ref.read(centralWidgetNotifierProvider.notifier);
    final ThemeData theme = Theme.of(context);
    final Color textColor = dateTime.isBefore(DateTime.now())
        ? theme.colorScheme.onErrorContainer
        : noRush
            ? theme.colorScheme.onSecondaryContainer
            : theme.colorScheme.onTertiaryContainer;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!noRush)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (centralElement != CentralElement.dateTimeGrid) {
                  centralElementNotififer.switchTo(CentralElement.dateTimeGrid);
                } else {
                  centralElementNotififer.switchTo(CentralElement.timePicker);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      getFormattedDateTime(dateTime),
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: textColor,
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
                              color: textColor,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
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

    final dateTime = ref.watch(sheetReminderNotifier.select((p) => p.dateTime));
    final isNoRush = ref.watch(sheetReminderNotifier.select((p) => p.noRush));
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
          if (isNoRush) return SizedBox.shrink();
          switch (element) {
            case CentralElement.dateTimeGrid:
              return _buildTimeButtonsGrid(settings);
            case CentralElement.timePicker:
              return _buildTimePicker(
                ref,
                dateTime,
              );
            case CentralElement.snoozeOptions:
              return ReminderSnoozeOptionsWidget(
                key: UniqueKey(),
              );
            case CentralElement.recurrenceOptions:
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
        physics: NeverScrollableScrollPhysics(),
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
      child: CupertinoDatePicker(
        initialDateTime: dateTime,
        itemExtent: 75,
        onDateTimeChanged: (DateTime dt) =>
            ref.read(sheetReminderNotifier).updateDateTime(dt),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
