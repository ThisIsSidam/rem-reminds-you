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

  /// Like a normal fromJson.
  /// [asNew] property shows whether the entity should be treated as a new
  /// entity or not, new entities would be given hardcoded id 0
  factory ReminderEntity.fromJson(
    Map<String, dynamic> json, {
    bool asNew = false,
  }) =>
      ReminderEntity(
        id: asNew ? 0 : json['id'] as int,
        title: json['title'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        preParsedTitle: json['preParsedTitle'] as String,
        autoSnoozeInterval: json['autoSnoozeInterval'] as int,
        recurringInterval: json['recurringInterval'] as String,
        baseDateTime: DateTime.parse(json['baseDateTime'] as String),
        paused: json['paused'] as bool,
      );

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

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'dateTime': dateTime.toIso8601String(),
        'preParsedTitle': preParsedTitle,
        'autoSnoozeInterval': autoSnoozeInterval,
        'recurringInterval': recurringInterval,
        'baseDateTime': baseDateTime.toIso8601String(),
        'paused': paused,
      };
}
