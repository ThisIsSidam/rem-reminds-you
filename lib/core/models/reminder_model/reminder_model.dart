import 'package:hive_ce_flutter/hive_flutter.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 0)
class ReminderModel {
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

  ReminderModel({
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

  factory ReminderModel.fromJson(Map<String, String?> json) {
    return ReminderModel(
      id: int.parse(json['id']!),
      title: json['title']!,
      dateTime: DateTime.parse(json['dateTime']!),
      PreParsedTitle: json['PreParsedTitle']!,
      autoSnoozeInterval: json['autoSnoozeInterval'] != null
          ? Duration(milliseconds: int.parse(json['autoSnoozeInterval']!))
          : null,
    );
  }

  ReminderModel copyWith({
    int? id,
    String? title,
    DateTime? dateTime,
    String? preParsedTitle,
    Duration? autoSnoozeInterval,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      PreParsedTitle: preParsedTitle ?? this.PreParsedTitle,
      autoSnoozeInterval: autoSnoozeInterval ?? this.autoSnoozeInterval,
    );
  }

  bool compareTo(ReminderModel other) {
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
