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

  /// Like a normal fromJson.
  /// [asNew] property shows whether the entity should be treated as a new
  /// entity or not, new entities would be given hardcoded id 0
  factory NoRushReminderEntity.fromJson(
    Map<String, dynamic> json, {
    bool asNew = false,
  }) {
    return NoRushReminderEntity(
      id: asNew ? 0 : json['id'] as int,
      title: json['title'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      autoSnoozeInterval: json['autoSnoozeInterval'] as int,
    );
  }

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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'autoSnoozeInterval': autoSnoozeInterval,
    };
  }
}
