// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../app/constants/const_strings.dart';
import '../../../feature/reminder/data/models/reminder_base.dart';
import '../../../objectbox.g.dart';
import '../../../shared/utils/id_handler.dart';
import '../../../shared/utils/logger/app_logger.dart';
import 'notification_action_handler.dart';
import 'notification_channels.dart';

@pragma('vm:entry-point')
class NotificationController {
  static Future<void> initializeLocalNotifications() async {
    await AndroidAlarmManager.initialize();

    await AwesomeNotifications().initialize(
      null,
      NotificationChannels.channels,
    );

    _log('Initialized Notifications');
  }

  static ReceivedAction? initialAction;

  /// Check permission status
  static Future<bool> checkNotificationPermissions() async {
    final bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    return isAllowed;
  }

  /// Request for notification permission
  static Future<bool> requestNotificationPermission() async {
    return AwesomeNotifications().requestPermissionToSendNotifications();
  }

  /// Waits for 2 seconds to get initialAction. Defaults to setting it
  /// to null if not received within timeout.
  static Future<void> interceptInitialCallActionRequest() async {
    // Get and save initialAction. Will be fetched and used in SplashScreen.
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: true)
        .timeout(const Duration(seconds: 2), onTimeout: () => null);
  }

  /// Schedule an alarm for the reminder with callback to show the notification.
  /// [reminder] is used to generate the payload of the alarm and notification.
  @pragma('vm:entry-point')
  static Future<bool> scheduleReminder(ReminderBase reminder) async {
    final int id = reminder.id;
    final DateTime scheduledTime = reminder.dateTime;

    _log('Notification Scheduled | ID: $id | DT : $scheduledTime');
    final Map<String, String?> params = reminder.toJson();

    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      IdHandler.getReminderAlarmId(reminder),
      showReminderNotificationCallback,
      allowWhileIdle: true,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      params: params,
    );

    return true;
  }

  /// Callback to be attached to alarms, which recieves payload from alarm.
  /// Shows notification for the reminder.
  @pragma('vm:entry-point')
  static Future<void> showReminderNotificationCallback(
    int id,
    Map<String, dynamic> params,
  ) async {
    await AppLogger.init();
    _log('Notification Callback Running | callBackId: $id');

    final Map<String, String> strParams = params.cast<String, String>();
    final ReminderBase reminder = ReminderBase.fromJson(strParams);

    // Should be different each time so that different notifications are shown.
    final int notificationId = IdHandler.getReminderNotificationId(reminder.id);
    final Map<String, String?> payload = reminder.toJson();

    _log('Showing notification | notificationID: $notificationId');

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: NotificationChannels.reminder.key,
        title: 'Reminder: ${reminder.title}',
        groupKey: IdHandler.getReminderGroupKey(reminder),
        wakeUpScreen: true,
        payload: payload,
      ),
      actionButtons: <NotificationActionButton>[
        NotificationActionButton(
          key: 'done',
          label: 'Done',
          actionType: ActionType.SilentBackgroundAction,
        ),
        NotificationActionButton(
          key: 'postpone',
          label: 'Postpone',
          actionType: ActionType.SilentBackgroundAction,
        ),
      ],
    );

    // Get next schedule time
    final DateTime nextScheduledTime = reminder.dateTime.add(
      reminder.autoSnoozeInterval,
    );

    // Update the reminder with the next schedule time and schedule
    // another notification for the reminder
    reminder.dateTime = nextScheduledTime;
    await scheduleReminder(reminder);
    _log(
      'Scheduled Next Notification- ID:${reminder.id} | DT:${reminder.dateTime}',
    );
  }

  /// Used to remove notifications present in user's notification space.
  static Future<void> removeNotifications(String? groupKey) async {
    if (groupKey == null) {
      AppLogger.w('Received null groupKey in removeNotifications');
      return;
    }

    await AwesomeNotifications().cancelNotificationsByGroupKey(groupKey);
    _log('Cleared present notifications | gKey : $groupKey');
  }

  /// Cancels the scheduled notification.
  static Future<void> cancelScheduledNotification(String? groupKey) async {
    if (groupKey == null) {
      AppLogger.w('Received null groupKey in cancelScheduleNotification');
      return;
    }

    // Cancelling through ALM coz AwesomeN is used to only send notification.
    // It has no hands in scheduling notifications.
    await AndroidAlarmManager.cancel(int.tryParse(groupKey) ?? -1);
    await removeNotifications(groupKey);
    _log('Cancelled scheduled notifications | gKey : $groupKey');
  }

  static Future<void> startListeningNotificationEvents() async {
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );

    _log('Started Listening to notification events');
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    await AppLogger.init();
    _log('Received notification action | Action: ${receivedAction.actionType}');
    if (receivedAction.payload == null) return;
    final ReminderBase reminder = ReminderBase.fromJson(
      receivedAction.payload!,
    );
    await cancelScheduledNotification(
      receivedAction.groupKey ?? notificationNullGroupKey,
    );
    final Store store = await getObjectboxStore();
    final NotificationActionHandler actionHandler = NotificationActionHandler(
      reminder: reminder,
      store: store,
    );

    if (receivedAction.buttonKeyPressed == 'done') {
      actionHandler.donePressed();
    } else if (receivedAction.buttonKeyPressed == 'postpone') {
      await actionHandler.postponePressed();
    }
    store.close();
  }

  /// Get future to Objectbox Store instance
  ///
  /// If store is already open (in case app is active), attachs to that
  /// instance, or returns a new instance.
  @pragma('vm:entry-point')
  static Future<Store> getObjectboxStore() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    if (Store.isOpen(path.join(dir.path, 'objectbox-activity-store'))) {
      return Store.attach(
        getObjectBoxModel(),
        path.join(dir.path, 'objectbox-activity-store'),
      );
    } else {
      return Store(
        getObjectBoxModel(),
        directory: path.join(dir.path, 'objectbox-activity-store'),
      );
    }
  }

  static void _log(String msg) => AppLogger.i('[NotificationController] $msg');
}
