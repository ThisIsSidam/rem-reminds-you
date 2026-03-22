import '../../entities/reminder_entitiy/reminder_entity.dart';
import '../recurring_interval/recurrence_engine.dart';
import '../recurring_interval/recurrence_rule.dart';
import '../reminder_base/reminder_base.dart';

/// One of the implementations of [ReminderBase].
/// Features like recurring intervals and title parsing make use of
/// this model.
class ReminderModel implements ReminderBase {
  ReminderModel({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.preParsedTitle,
    required this.autoSnoozeInterval,
    required this.recurrenceRule,
    required this.baseDateTime,
    this.paused = false,
  });

  factory ReminderModel.fromJson(Map<String, String?> map) {
    return ReminderModel(
      id: int.parse(map['id']!),
      title: map['title'] ?? '',
      dateTime: DateTime.parse(map['dateTime']!),
      autoSnoozeInterval:
          Duration(seconds: int.parse(map['autoSnoozeInterval']!)),
      preParsedTitle: map['preParsedTitle'] ?? '',
      recurrenceRule: RecurrenceRule.fromString(
        map['recurringRule'] ?? '',
      ),
      baseDateTime: DateTime.parse(map['baseDateTime'] ?? map['dateTime']!),
      paused: map['paused']! == 'true',
    );
  }

  @override
  int id;
  @override
  String title;
  @override
  DateTime dateTime;
  String preParsedTitle;
  @override
  Duration autoSnoozeInterval;
  RecurrenceRule recurrenceRule;

  /// Refers to the initial [DateTime] set for the reminder.
  /// This does not change if user postpones a reminder.
  DateTime baseDateTime;
  bool paused;

  bool get isRecurring => !recurrenceRule.isNone;
  bool get isNotRecurring => recurrenceRule.isNone;

  @override
  Map<String, String?> toJson() {
    return <String, String>{
      'id': id.toString(),
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'preParsedTitle': preParsedTitle,
      'autoSnoozeInterval': autoSnoozeInterval.inSeconds.toString(),
      'recurrenceRule': recurrenceRule.toString(),
      'baseDateTime': baseDateTime.toIso8601String(),
      'paused': paused.toString(),
      'type': '1',
    };
  }

  ReminderModel copyWith({
    int? id,
    String? title,
    DateTime? dateTime,
    Duration? autoSnoozeInterval,
    String? preParsedTitle,
    RecurrenceRule? recurrenceRule,
    DateTime? baseDateTime,
    bool? paused,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      autoSnoozeInterval: autoSnoozeInterval ?? this.autoSnoozeInterval,
      preParsedTitle: preParsedTitle ?? this.preParsedTitle,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      baseDateTime: baseDateTime ?? this.baseDateTime,
      paused: paused ?? this.paused,
    );
  }

  void moveToNextOccurrence() {
    _incrementRecurDuration();
    dateTime = baseDateTime;
  }

  void _incrementRecurDuration() {
    final Duration? increment = RecurrenceEngine.nextOccurense(
      base: dateTime,
      rule: recurrenceRule,
    );

    if (increment != null) {
      baseDateTime = baseDateTime.add(increment);
    }
  }

  ReminderEntity get toEntity => ReminderEntity(
        id: id,
        title: title,
        dateTime: dateTime,
        preParsedTitle: preParsedTitle,
        autoSnoozeInterval: autoSnoozeInterval.inSeconds,
        recurringInterval: recurrenceRule.toString(),
        recurrenceRule: recurrenceRule.toString(),
        baseDateTime: baseDateTime,
        paused: paused,
      );
}

extension ReminderX on ReminderModel {
  int compareTo(ReminderModel other) {
    return dateTime.compareTo(other.dateTime);
  }

  Duration getDiffDuration() {
    return dateTime.difference(DateTime.now());
  }

  /// Check if the current date and time is before 5 seconds from the
  /// reminder's date and time.
  bool isTimesUp() {
    return dateTime.isBefore(DateTime.now().add(const Duration(seconds: 5)));
  }

  DateTime getPostponeDt(Duration dur) {
    final DateTime now = DateTime.now();
    if (dateTime.isBefore(now)) {
      return now.add(dur);
    } else {
      return dateTime.add(dur);
    }
  }
}
