import 'package:hive/hive.dart';

part 'reminder_modal.g.dart';

@HiveType(typeId: 0)
class ReminderModal {
  @HiveField(0)
  int id;
  @HiveField(1)
  String title;
  @HiveField(2)
  DateTime dateTime;
  @HiveField(3)
  String PreParsedTitle;
  @HiveField(4)
  Duration? autoSnoozeInterval;
  ReminderModal({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.PreParsedTitle,
    this.autoSnoozeInterval,
  });

  Map<String, String?> toJson() {
    return {
      'id': id.toString(),
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'PreParsedTitle': PreParsedTitle,
      'autoSnoozeInterval': autoSnoozeInterval?.inMilliseconds.toString(),
    };
  }

  factory ReminderModal.fromJson(Map<String, String?> json) {
    return ReminderModal(
      id: int.parse(json['id']!),
      title: json['title']!,
      dateTime: DateTime.parse(json['dateTime']!),
      PreParsedTitle: json['PreParsedTitle']!,
      autoSnoozeInterval: json['autoSnoozeInterval'] != null
          ? Duration(milliseconds: int.parse(json['autoSnoozeInterval']!))
          : null,
    );
  }

  ReminderModal copyWith({
    int? id,
    String? title,
    DateTime? dateTime,
    String? preParsedTitle,
    Duration? autoSnoozeInterval,
  }) {
    return ReminderModal(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      PreParsedTitle: preParsedTitle ?? this.PreParsedTitle,
      autoSnoozeInterval: autoSnoozeInterval ?? this.autoSnoozeInterval,
    );
  }

  bool compareTo(ReminderModal other) {
    return dateTime.isBefore(other.dateTime);
  }

  Duration getDiffDuration() {
    return dateTime.difference(DateTime.now());
  }

  /// Check if the current date and time is before 5 seconds from the reminder's date and time.
  bool isTimesUp() {
    return dateTime.isBefore(DateTime.now().add(Duration(seconds: 5)));
  }
}
