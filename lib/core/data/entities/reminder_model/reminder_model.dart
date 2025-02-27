import 'package:objectbox/objectbox.dart';

@Entity()
class ReminderEntity {
  ReminderEntity({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.preParsedTitle,
    this.autoSnoozeInterval,
  });

  int id;
  String title;
  DateTime dateTime;
  String preParsedTitle;
  int? autoSnoozeInterval;
}
