import 'dart:math';

import 'package:hive/hive.dart';

import '../reminder_modal/reminder_modal.dart';

part 'no_rush_reminders.g.dart';

@HiveType(typeId: 3)
class NoRushRemindersModal extends ReminderModal {
  NoRushRemindersModal({
    required super.id,
    required super.title,
    required super.autoSnoozeInterval,
  }) : super(PreParsedTitle: title, dateTime: _generateRandomFutureTime());

  // Will use fromJson and toJson methods of ReminderModal as the attributes
  // are same

  /// Generate DateTime for this new noRush reminder.
  static DateTime _generateRandomFutureTime() {
    final random = Random();
    final now = DateTime.now();

    // Calculate start date (3 days from now) and end date (14 days from now)
    final startDate = now.add(const Duration(days: 3));
    final endDate = now.add(const Duration(days: 14));

    // Calculate the range in days and get a random day within that range
    final rangeDays = endDate.difference(startDate).inDays;
    final randomDays = random.nextInt(rangeDays);
    final randomDate = startDate.add(Duration(days: randomDays));

    // Generate random hour between 6 AM and 10 PM (22:00)
    final startHour = 6;
    final endHour = 22;
    final randomHour = startHour + random.nextInt(endHour - startHour + 1);

    // Generate random minutes and seconds
    final randomMinute = random.nextInt(60);
    final randomSecond = random.nextInt(60);

    // Combine the random date with random time
    return DateTime(
      randomDate.year,
      randomDate.month,
      randomDate.day,
      randomHour,
      randomMinute,
      randomSecond,
    );
  }
}
