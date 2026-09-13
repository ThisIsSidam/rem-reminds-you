import 'package:awesome_notifications/awesome_notifications.dart';

enum NotificationActions {
  reminderDone('done', 'Done', .SilentBackgroundAction),
  reminderPostpone('postpone', 'Postpone', .SilentBackgroundAction);

  const NotificationActions(this.key, this.label, this.actionType);

  final String key;
  final String label;
  final ActionType actionType;

  NotificationActionButton get button =>
      NotificationActionButton(key: key, label: label, actionType: actionType);

  static List<NotificationActions> get reminderActions => [
    reminderDone,
    reminderPostpone,
  ];

  static bool isReminderAction(String key) =>
      reminderActions.any((action) => action.key == key);
}
