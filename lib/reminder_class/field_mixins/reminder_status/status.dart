import 'package:Rem/reminder_class/reminder.dart';
import 'package:hive/hive.dart';

mixin ReminderStatusMixin {

  @HiveField(3)
  int mixinReminderStatus = 0; // Is an enum but saved as int coz saving enums in hive is a problem.

  ReminderStatus get reminderStatus {
    return RemindersStatusExtension.fromInt(mixinReminderStatus);
  }

  void set reminderStatus(ReminderStatus status) {
    mixinReminderStatus = RemindersStatusExtension.getIndex(status);
  }
}