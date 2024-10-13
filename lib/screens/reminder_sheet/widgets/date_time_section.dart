import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/screens/reminder_sheet/widgets/time_button.dart';
import 'package:Rem/utils/datetime_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  final List<DateTime> setDateTimes = List.generate(4, (index) {
    final dt = UserDB.getSetting(SettingsOptionMethods.fromInt(index+3));
    if (!(dt is DateTime))
    {
      throw "[setDateTimes] DateTime not received | $dt";
    } 
    return dt;
  }, growable: false);

  final List<Duration>  editDurations = List.generate(8, (index) {
    final dur = UserDB.getSetting(SettingsOptionMethods.fromInt(index+7));
    if  (!(dur is Duration)) 
    {
      throw "[editDurations] Duration not received | $dur";
    }
    return dur; 
  }, growable: false);

  @override
  Widget build(BuildContext context) {
    final reminder = ref.watch(reminderNotifierProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ElevatedButton(
            style: Theme.of(context).elevatedButtonTheme.style,
            onPressed: () {
              setState(() {
                showTimePicker = !showTimePicker;
              });
            }, // to be implemented
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getFormattedDateTime(reminder.dateAndTime),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(width: 24,),
                Flexible(
                  child: Text(
                    reminder.dateAndTime.isBefore(DateTime.now())
                    ? '${getPrettyDurationFromDateTime(reminder.dateAndTime)} ago'.replaceFirst('-', '')
                    : 'in ${getPrettyDurationFromDateTime(reminder.dateAndTime)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          ),
          const SizedBox(height: 8,),
          showTimePicker 
          ? _buildTimePicker(
            reminder,
            ref
          ) 
          : _buildTimeButtonsGrid(),
        ],
      ),
    );
  }

  Widget _buildTimeButtonsGrid() {
    return GridView.count(
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      crossAxisCount: 4,
      shrinkWrap: true,
      childAspectRatio: 1.5,
      children: [
        TimeButton(dateTime: setDateTimes[0]),
        TimeButton(dateTime: setDateTimes[1]),
        TimeButton(dateTime: setDateTimes[2]),
        TimeButton(dateTime: setDateTimes[3]),
        TimeButton(duration: editDurations[0]),
        TimeButton(duration: editDurations[1]),
        TimeButton(duration: editDurations[2]),
        TimeButton(duration: editDurations[3]),
        TimeButton(duration: editDurations[4]),
        TimeButton(duration: editDurations[5]),
        TimeButton(duration: editDurations[6]),
        TimeButton(duration: editDurations[7]),
      ],
    );
  }

  Widget _buildTimePicker(
    Reminder reminder,
    WidgetRef ref
  ) {
    final reminderNotifier = ref.read(reminderNotifierProvider.notifier);  

    return SizedBox(
      height: 175,
      child: CupertinoTheme(
        data: CupertinoThemeData(
          brightness: Brightness.dark
        ),
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