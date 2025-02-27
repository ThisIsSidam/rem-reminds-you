import 'package:objectbox/objectbox.dart';

import '../../models/recurring_interval/recurring_interval.dart';
import '../../models/reminder/reminder.dart';

@Entity()
class ReminderEntity {
  ReminderEntity({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.preParsedTitle,
    required this.autoSnoozeInterval,
    required this.recurringInterval,
    required this.baseDateTime,
    this.paused = false,
  });

  int id;
  String title;
  DateTime dateTime;
  String preParsedTitle;
  int autoSnoozeInterval;
  String recurringInterval;
  @Property(type: PropertyType.date)
  DateTime baseDateTime;
  bool paused;

  ReminderModel get toModel {
    return ReminderModel(
      id: id,
      title: title,
      dateTime: dateTime,
      preParsedTitle: preParsedTitle,
      autoSnoozeInterval: Duration(seconds: autoSnoozeInterval),
      recurringInterval: RecurringInterval.fromString(recurringInterval),
      baseDateTime: baseDateTime,
      paused: paused,
    );
  }
}
