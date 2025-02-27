import 'package:objectbox/objectbox.dart';

import '../reminder_model/reminder_model.dart';

@Entity()
class NoRushRemindersEntity implements ReminderEntity {
  NoRushRemindersEntity({
    required this.id,
    required this.title,
    required this.autoSnoozeInterval,
    required this.dateTime,
  }) : preParsedTitle = title;

  @override
  int id;
  @override
  String title;
  @override
  DateTime dateTime;
  @override
  String preParsedTitle;
  @override
  int? autoSnoozeInterval;
}
