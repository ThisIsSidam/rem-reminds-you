import 'package:awesome_notifications/awesome_notifications.dart';

enum NotificationChannels {
  reminder(
    'reminders',
    'Reminder notifications',
    'Shows notifications for reminders you create.',
    NotificationImportance.High,
  ),
  agenda(
    'agenda',
    'Agenda notificaitons',
    "Shows notification for the day's agenda.",
    NotificationImportance.High,
  );

  const NotificationChannels(
    this.key,
    this.name,
    this.description,
    this.importance,
  );

  final String key;
  final String name;
  final String description;
  final NotificationImportance importance;

  static List<NotificationChannel> get channels =>
      values.map((NotificationChannels e) => e.channel).toList();

  NotificationChannel get channel => NotificationChannel(
        channelKey: key,
        channelName: name,
        channelDescription: description,
        importance: importance,
        soundSource: 'resource://raw/res_default_sound',
        playSound: true,
      );
}
