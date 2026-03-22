import 'package:objectbox/objectbox.dart';

import '../../models/recurring_interval/recurrence_rule.dart';
import '../../models/reminder/reminder.dart';

/// Used for Objectbox storage of [ReminderModel].
///
/// To make sure reminders created before addition of [recurrenceRule] are
/// handled, the [recurringInterval] hasn't been removed. But will be.
@Entity()
class ReminderEntity {
  ReminderEntity({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.preParsedTitle,
    required this.autoSnoozeInterval,
    @Deprecated('Use recurrenceRule instead. Just a rename.')
    required this.recurringInterval,
    required this.recurrenceRule,
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
        recurringInterval: json['recurringInterval'] as String? ?? '',
        recurrenceRule: json['recurrenceRule'] as String? ?? '',
        baseDateTime: DateTime.parse(json['baseDateTime'] as String),
        paused: json['paused'] as bool,
      );

  int id;
  String title;
  DateTime dateTime;
  String preParsedTitle;
  int autoSnoozeInterval;
  @Deprecated("Use 'recurrenceRule' instead. Just a rename.")
  String recurringInterval;
  String recurrenceRule;
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
      recurrenceRule: RecurrenceRule.fromString(
        // If an old instance, data will be in recurringInterval.
        recurrenceRule.isEmpty ? recurringInterval : recurrenceRule,
      ),
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
        'recurrenceRule': recurrenceRule,
        'baseDateTime': baseDateTime.toIso8601String(),
        'paused': paused,
      };
}
