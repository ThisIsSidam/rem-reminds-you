import 'package:objectbox/objectbox.dart';

import '../../models/no_rush_reminder/no_rush_reminder.dart';

@Entity()
class NoRushReminderEntity {
  NoRushReminderEntity({
    required this.id,
    required this.title,
    required this.autoSnoozeInterval,
    required this.dateTime,
  });

  int id;
  String title;
  DateTime dateTime;
  int autoSnoozeInterval;

  NoRushReminderModel get toModel {
    return NoRushReminderModel(
      id: id,
      title: title,
      dateTime: dateTime,
      autoSnoozeInterval: Duration(seconds: autoSnoozeInterval),
    );
  }
}
