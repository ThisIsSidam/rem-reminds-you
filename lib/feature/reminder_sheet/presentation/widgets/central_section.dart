import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../shared/utils/datetime_methods.dart';
import '../../../../shared/utils/logger/global_logger.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../providers/central_widget_provider.dart';
import '../providers/sheet_reminder_notifier.dart';
import 'bottom_elements/recurrence_options.dart';
import 'bottom_elements/snooze_options.dart';
import 'time_button.dart';

class CentralSection extends HookConsumerWidget {
  const CentralSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime dateTime = ref.watch(
      sheetReminderNotifier.select((SheetReminderNotifier p) => p.dateTime),
    );
    final bool noRush = ref.watch(
      sheetReminderNotifier.select((SheetReminderNotifier p) => p.noRush),
    );
    final CentralElement centralElement =
        ref.watch(centralWidgetNotifierProvider);
    final CentralWidgetNotifier centralElementNotififer =
        ref.read(centralWidgetNotifierProvider.notifier);
    final ThemeData theme = Theme.of(context);
    final Color textColor = dateTime.isBefore(DateTime.now())
        ? theme.colorScheme.onErrorContainer
        : noRush
            ? theme.colorScheme.onSecondaryContainer
            : theme.colorScheme.onTertiaryContainer;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
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
                  vertical: 8,
                  horizontal: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
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
        const CentralWidget(),
      ],
    );
  }
}

class CentralWidget extends ConsumerWidget {
  const CentralWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CentralElement element = ref.watch(centralWidgetNotifierProvider);
    final UserSettingsNotifier settings = ref.watch(userSettingsProvider);

    final DateTime dateTime = ref.watch(
      sheetReminderNotifier.select((SheetReminderNotifier p) => p.dateTime),
    );
    final bool isNoRush = ref.watch(
      sheetReminderNotifier.select((SheetReminderNotifier p) => p.noRush),
    );
    if (element != CentralElement.dateTimeGrid) {
      gLogger.i('Bottom element changed, un-focusing');
    }
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutQuad,
        switchOutCurve: Curves.easeInQuad,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0, 0.8, curve: Curves.easeOutQuad),
              ),
            ),
            child: child,
          );
        },
        child: () {
          if (isNoRush) return const SizedBox.shrink();
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
    final List<DateTime> setDateTimes = <DateTime>[
      settings.quickTimeSetOption1,
      settings.quickTimeSetOption2,
      settings.quickTimeSetOption3,
      settings.quickTimeSetOption4,
    ];

    // Get the duration options from settings
    final List<Duration> editDurations = <Duration>[
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
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        crossAxisCount: 4,
        shrinkWrap: true,
        childAspectRatio: 1.5,
        children: <Widget>[
          ...setDateTimes.map(
            (DateTime dateTime) => TimeSetButton(dateTime: dateTime),
          ),
          ...editDurations.map(
            (Duration duration) => TimeEditButton(duration: duration),
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
