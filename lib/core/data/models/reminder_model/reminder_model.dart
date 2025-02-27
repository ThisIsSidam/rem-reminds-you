class ReminderModel {
  ReminderModel({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.preParsedTitle,
    this.autoSnoozeInterval,
  });

  factory ReminderModel.fromJson(Map<String, String?> json) {
    return ReminderModel(
      id: int.parse(json['id']!),
      title: json['title'] ?? '',
      dateTime: DateTime.parse(json['dateTime']!),
      preParsedTitle: json['PreParsedTitle'] ?? '',
      autoSnoozeInterval: json['autoSnoozeInterval'] != null
          ? Duration(milliseconds: int.parse(json['autoSnoozeInterval']!))
          : null,
    );
  }
  int id;
  String title;
  DateTime dateTime;
  String preParsedTitle;
  Duration? autoSnoozeInterval;

  Map<String, String?> toJson() {
    return <String, String?>{
      'id': id.toString(),
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'PreParsedTitle': preParsedTitle,
      'autoSnoozeInterval': autoSnoozeInterval?.inMilliseconds.toString(),
    };
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
      preParsedTitle: preParsedTitle ?? this.preParsedTitle,
      autoSnoozeInterval: autoSnoozeInterval ?? this.autoSnoozeInterval,
    );
  }
}

extension ReminderX on ReminderModel {
  bool compareTo(ReminderModel other) {
    return dateTime.isBefore(other.dateTime);
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
