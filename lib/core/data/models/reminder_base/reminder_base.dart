import '../no_rush_reminder/no_rush_reminder.dart';
import '../reminder/reminder.dart';

abstract interface class ReminderBase {
  ReminderBase({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.autoSnoozeInterval,
  });

  // type-id 1 refers to normal reminders while 2 refers to no-rush reminders
  // Do not change these ids
  factory ReminderBase.fromJson(Map<String, String?> json) {
    final String? type = json['type'];
    if (type == null || type == '1') {
      return ReminderModel.fromJson(json);
    } else if (type == '2') {
      return NoRushReminderModel.fromJson(json);
    } else {
      throw 'Unhandled reminder type: $type';
    }
  }

  int id;
  String title;
  DateTime dateTime;
  Duration autoSnoozeInterval;

  // type-id 1 refers to normal reminders while 2 refers to no-rush reminders
  // Do not change these ids
  Map<String, String?> toJson();
}
