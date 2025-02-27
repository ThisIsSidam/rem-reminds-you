import '../recurring_interval/recurring_interval.dart';
import '../reminder_model/reminder_model.dart';

class RecurringReminderModel implements ReminderModel {
  RecurringReminderModel({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.preParsedTitle,
    required this.autoSnoozeInterval,
    required this.recurringInterval,
    required this.baseDateTime,
    this.paused = false,
  });

  factory RecurringReminderModel.fromJson(Map<String, String?> map) {
    return RecurringReminderModel(
      id: int.parse(map['id']!),
      title: map['title'] ?? '',
      dateTime: DateTime.parse(map['dateTime']!),
      autoSnoozeInterval:
          Duration(milliseconds: int.parse(map['autoSnoozeInterval']!)),
      preParsedTitle: map['preParsedTitle'] ?? '',
      recurringInterval: RecurringInterval.fromString(
        map['recurringInterval'] ?? '',
      ),
      baseDateTime: DateTime.parse(map['baseDateTime']!),
      paused: map['paused']! == 'true',
    );
  }

  @override
  int id;
  @override
  String title;
  @override
  DateTime dateTime;
  @override
  String preParsedTitle;
  @override
  Duration? autoSnoozeInterval;
  RecurringInterval recurringInterval;
  DateTime baseDateTime;
  bool paused;

  @override
  Map<String, String?> toJson() {
    return <String, String?>{
      'id': id.toString(),
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'preParsedTitle': preParsedTitle,
      'autoSnoozeInterval': autoSnoozeInterval?.inMilliseconds.toString(),
      'recurringInterval': recurringInterval.toString(),
      'baseDateTime': baseDateTime.toIso8601String(),
      'paused': paused.toString(),
    };
  }

  @override
  RecurringReminderModel copyWith({
    int? id,
    String? title,
    DateTime? dateTime,
    Duration? autoSnoozeInterval,
    String? preParsedTitle,
    RecurringInterval? recurringInterval,
    DateTime? baseDateTime,
    bool? paused,
  }) {
    return RecurringReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      autoSnoozeInterval: autoSnoozeInterval ?? this.autoSnoozeInterval,
      preParsedTitle: preParsedTitle ?? this.preParsedTitle,
      recurringInterval: recurringInterval ?? this.recurringInterval,
      baseDateTime: baseDateTime ?? this.baseDateTime,
      paused: paused ?? this.paused,
    );
  }

  void moveToNextOccurrence() {
    _incrementRecurDuration();
    dateTime = baseDateTime;
  }

  void moveToPreviousOccurrence() {
    _decrementRecurDuration();
    dateTime = baseDateTime;
  }

  void _incrementRecurDuration() {
    final Duration? increment = recurringInterval.toNext();

    if (increment != null) {
      baseDateTime = baseDateTime.add(increment);
    }
  }

  void _decrementRecurDuration() {
    final Duration? decrement = recurringInterval.toPrevious();

    if (decrement != null) {
      baseDateTime = baseDateTime.subtract(decrement);
    }
  }
}
