interface class ReminderBase {
  ReminderBase({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.autoSnoozeInterval,
  });

  factory ReminderBase.fromJson(Map<String, String?> json) {
    return ReminderBase(
      id: int.parse(json['id']!),
      title: json['title']!,
      dateTime: DateTime.parse(json['dateTime']!),
      autoSnoozeInterval:
          Duration(seconds: int.parse(json['autoSnoozeInterval']!)),
    );
  }

  int id;
  String title;
  DateTime dateTime;
  Duration autoSnoozeInterval;

  Map<String, String?> toJson() {
    return <String, String>{
      'id': id.toString(),
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'autoSnoozeInterval': autoSnoozeInterval.inSeconds.toString(),
    };
  }
}
