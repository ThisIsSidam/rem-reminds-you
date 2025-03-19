import '../../core/data/models/no_rush_reminder/no_rush_reminder.dart';
import '../../core/data/models/reminder_base/reminder_base.dart';

class IdHandler {
  @pragma('vm:entry-point')
  int getNotificationId(int id) {
    final int secondsSinceEpoch =
        DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerSecond;
    final String minutes = secondsSinceEpoch.toString();
    final int len = minutes.length;
    return int.parse(id.toString() + minutes.substring(len - 6));
  }

  @pragma('vm:entry-point')
  int getAlarmId(ReminderBase reminder) {
    if (reminder is NoRushReminderModel) {
      return reminder.id + 100000;
    } else {
      return reminder.id;
    }
  }

  String getGroupKey(ReminderBase reminder) {
    if (reminder is NoRushReminderModel) {
      return 'noRush${reminder.id}';
    }
    return reminder.id.toString();
  }
}
