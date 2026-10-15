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
      reminderActions.any((action) => action.key == key) ||
      QuickTimeNotificationAction.indexFromKey(key) != null;
}

/// Button keys for the 12 quick-time-table options rendered as a
/// [NotificationLayout.QuickTimeGrid] grid (see `rem-android-awn-core`).
/// Index 0-3 are the absolute-time options (SettingsKey.quickTimeSetOption1-4),
/// 4-11 are the duration options (SettingsKey.quickTimeEditOption1-8) - same
/// order as [QuickTimeTableSheet]'s grid.
class QuickTimeNotificationAction {
  const QuickTimeNotificationAction._();

  static const String _keyPrefix = 'quick_';
  static const int optionCount = 12;

  static String keyForIndex(int index) => '$_keyPrefix$index';

  static int? indexFromKey(String key) {
    if (!key.startsWith(_keyPrefix)) return null;
    return int.tryParse(key.substring(_keyPrefix.length));
  }
}
