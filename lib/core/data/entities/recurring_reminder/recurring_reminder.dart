import 'package:objectbox/objectbox.dart';

import '../reminder_model/reminder_model.dart';

@Entity()
class RecurringReminderEntity implements ReminderEntity {
  RecurringReminderEntity({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.preParsedTitle,
    required this.autoSnoozeInterval,
    required this.recurringInterval,
    required this.baseDateTime,
    this.paused = false,
  });

  @override
  int id;
  @override
  String title;
  @override
  DateTime dateTime;
  @override
  String preParsedTitle;
  @override
  @override
  int? autoSnoozeInterval;
  String recurringInterval;
  DateTime baseDateTime;
  bool paused;
}
