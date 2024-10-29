import 'package:hive/hive.dart';

mixin ReminderDateTime {
  @HiveField(2)
  DateTime dateAndTime = DateTime.now();

  /// If the time to be updated is in the past, increase it by a day.
  void updatedTime(DateTime updatedTime) {
    if (updatedTime.isBefore(DateTime.now())) {
      updatedTime = updatedTime.add(Duration(days: 1));
    }
    updatedTime = DateTime(
        // Seconds should be 0
        updatedTime.year,
        updatedTime.month,
        updatedTime.day,
        updatedTime.hour,
        updatedTime.minute,
        0);
    dateAndTime = updatedTime;
  }

  /// Check if the current date and time is before 5 seconds from the reminder's date and time.
  bool isTimesUp() {
    return dateAndTime.isBefore(DateTime.now().add(Duration(seconds: 5)));
  }
}
