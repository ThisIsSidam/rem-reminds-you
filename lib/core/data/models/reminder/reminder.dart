import '../../entities/reminder_entitiy/reminder_entity.dart';
import '../recurring_interval/recurring_interval.dart';

class ReminderModel {
  ReminderModel({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.preParsedTitle,
    required this.autoSnoozeInterval,
    required this.recurringInterval,
    required this.baseDateTime,
    this.paused = false,
  });

  factory ReminderModel.fromJson(Map<String, String?> map) {
    return ReminderModel(
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

  int id;
  String title;
  DateTime dateTime;
  String preParsedTitle;
  Duration autoSnoozeInterval;
  RecurringInterval recurringInterval;
  DateTime baseDateTime;
  bool paused;

  Map<String, String?> toJson() {
    return <String, String?>{
      'id': id.toString(),
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'preParsedTitle': preParsedTitle,
      'autoSnoozeInterval': autoSnoozeInterval.inMilliseconds.toString(),
      'recurringInterval': recurringInterval.toString(),
      'baseDateTime': baseDateTime.toIso8601String(),
      'paused': paused.toString(),
    };
  }

  ReminderModel copyWith({
    int? id,
    String? title,
    DateTime? dateTime,
    Duration? autoSnoozeInterval,
    String? preParsedTitle,
    RecurringInterval? recurringInterval,
    DateTime? baseDateTime,
    bool? paused,
  }) {
    return ReminderModel(
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

  ReminderEntity get toEntity => ReminderEntity(
        id: id,
        title: title,
        dateTime: dateTime,
        preParsedTitle: preParsedTitle,
        autoSnoozeInterval: autoSnoozeInterval.inSeconds,
        recurringInterval: recurringInterval.toString(),
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
}
