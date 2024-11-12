import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/screens/reminder_sheet/widgets/time_button.dart';
import 'package:Rem/utils/datetime_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../provider/settings_provider.dart';

class DateTimeSection extends ConsumerStatefulWidget {
  const DateTimeSection({super.key});

  @override
  ConsumerState<DateTimeSection> createState() => _DateTimeFieldState();
}

class _DateTimeFieldState extends ConsumerState<DateTimeSection> {
  final titleController = TextEditingController();
  bool showTimePicker = false;

  @override
  void initState() {
    final reminder = ref.read(reminderNotifierProvider);
    titleController.text = reminder.title;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final reminder = ref.watch(reminderNotifierProvider);
    final settings = ref.watch(userSettingsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {
            setState(
              () {
                showTimePicker = !showTimePicker;
              },
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                getFormattedDateTime(reminder.dateAndTime),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: reminder.dateAndTime.isBefore(DateTime.now())
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
              ),
              const SizedBox(
                width: 24,
              ),
              Flexible(
                child: Text(
                  reminder.dateAndTime.isBefore(DateTime.now())
                      ? '${getPrettyDurationFromDateTime(reminder.dateAndTime)} ago'
                          .replaceFirst('-', '')
                      : 'in ${getPrettyDurationFromDateTime(reminder.dateAndTime)}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: reminder.dateAndTime.isBefore(DateTime.now())
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
        AnimatedCrossFade(
          duration: Duration(milliseconds: 300),
          firstChild: _buildTimeButtonsGrid(settings),
          secondChild: _buildTimePicker(reminder, ref),
          crossFadeState: showTimePicker
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          sizeCurve: Curves.easeInOut,
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
          ...setDateTimes.map((dateTime) => TimeButton(dateTime: dateTime)),
          ...editDurations.map((duration) => TimeButton(duration: duration)),
        ],
      ),
    );
  }

  Widget _buildTimePicker(Reminder reminder, WidgetRef ref) {
    final reminderNotifier = ref.read(reminderNotifierProvider.notifier);

    return SizedBox(
      height: 175,
      child: CupertinoTheme(
        data: const CupertinoThemeData(brightness: Brightness.dark),
        child: CupertinoDatePicker(
          initialDateTime: reminder.dateAndTime,
          itemExtent: 75,
          onDateTimeChanged: (DateTime dt) {
            reminder.dateAndTime = dt;
            reminderNotifier.updateReminder(reminder);
          },
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
