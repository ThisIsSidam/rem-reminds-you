// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../../../app/constants/const_strings.dart';
import '../../../feature/agenda/data/models/agenda_task.dart';
import '../../../feature/reminder/data/models/reminder_base.dart';
import '../../../objectbox.g.dart';
import '../../../shared/utils/id_handler.dart';
import '../../../shared/utils/logger/app_logger.dart';
import 'agenda_notifications_helper.dart';
import 'notification_actions_enum.dart';
import 'notification_channels.dart';
import 'reminder_actions_handler.dart';

@pragma('vm:entry-point')
class NotificationController {
  // -----------------------------------------
  // ----- INIT ----------------------------------
  // -----------------------------------------

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

  // -----------------------------------------
  // ----- REMINDER ----------------------------------
  // -----------------------------------------

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
        NotificationActions.reminderDone.button,
        NotificationActions.reminderPostpone.button,
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

  // -----------------------------------------
  // ----- AGENDA ----------------------------------
  // -----------------------------------------

  @pragma('vm:entry-point')
  static Future<void> scheduleAgenda(DateTime scheduledTime) async {
    _log('Agenda Scheduled | DT: $scheduledTime');

    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      IdHandler.agendaAlarmId,
      showAgendaNotificationCallback,
      allowWhileIdle: true,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> showAgendaNotificationCallback(
    int id,
    Map<String, dynamic> params,
  ) async {
    await AppLogger.init();
    _log('Agenda Callback Running');

    final Store store = await _getObjectboxStore();
    final helper = AgendaNotificationsHelper(store: store);
    final NextAgendaTask nextTask = await helper.getNextTask();
    store.close();

    if (nextTask.task == null) {
      _log('No next task present');
      return;
    }

    await showAgendaNotification(task: nextTask.task!, isLast: nextTask.isLast);
  }

  @pragma('vm:entry-point')
  static Future<void> showAgendaNotification({
    required AgendaTask task,
    required bool isLast,
  }) async {
    final payload = <String, String>{'currentTaskId': task.id.toString()};

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: IdHandler.agendaNotificationId,
        channelKey: NotificationChannels.agenda.key,
        title: "Today's Agenda",
        body: task.title,
        locked: true,
        autoDismissible: false,
        payload: payload,
      ),
      actionButtons: [
        if (isLast)
          NotificationActions.agendaDone.button
        else
          NotificationActions.agendaNext.button,
      ],
    );
  }

  // -----------------------------------------
  // ----- NOTIFICATION HANDLERS --------------------------
  // -----------------------------------------

  /// Remove notifications using the notification [id].
  static Future<void> removeNotificationsById(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  /// Used to remove notifications present in user's notification space.
  static Future<void> removeNotificationsByGroupKey(String? groupKey) async {
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
    await removeNotificationsByGroupKey(groupKey);
    _log('Cancelled scheduled notifications | gKey : $groupKey');
  }

  // -----------------------------------------
  // ----- ACTION HANDLERS ----------------------------------
  // -----------------------------------------

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

    if (receivedAction.channelKey == NotificationChannels.reminder.key) {
      await _handleReminderNotificationAction(receivedAction);
    } else if (receivedAction.channelKey == NotificationChannels.agenda.key) {
      await _handleAgendaNotificationAction(receivedAction);
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _handleReminderNotificationAction(
    ReceivedAction receivedAction,
  ) async {
    final String buttonPressed = receivedAction.buttonKeyPressed;
    if (!NotificationActions.isReminderAction(buttonPressed)) return;

    // Get reminder from payload
    final ReminderBase reminder = ReminderBase.fromJson(
      receivedAction.payload!,
    );

    // Cancel all existing notifications of the reminder
    await cancelScheduledNotification(
      receivedAction.groupKey ?? notificationNullGroupKey,
    );

    // Get store, create action handler instance
    final Store store = await _getObjectboxStore();
    final actionHandler = ReminderActionsHandler(
      reminder: reminder,
      store: store,
    );

    // Handle action based on button pressed
    if (buttonPressed == NotificationActions.reminderDone.key) {
      actionHandler.donePressed();
    } else if (buttonPressed == NotificationActions.reminderPostpone.key) {
      await actionHandler.postponePressed();
    }

    // Close store
    store.close();
  }

  @pragma('vm:entry-point')
  static Future<void> _handleAgendaNotificationAction(
    ReceivedAction receivedAction,
  ) async {
    final buttonPressed = receivedAction.buttonKeyPressed;
    if (!NotificationActions.isAgendaActiono(buttonPressed)) return;

    // Parse task id
    final int? currentTaskId = int.tryParse(
      receivedAction.payload?['currentTaskId'] ?? '',
    );

    if (currentTaskId == null) return;

    // Get repository instance
    final Store store = await _getObjectboxStore();
    final handler = AgendaNotificationsHelper(store: store);

    // Handle action
    late final NextAgendaTask nextTask;
    if (buttonPressed == NotificationActions.agendaDone.key) {
      nextTask = await handler.nextPressed(currentTaskId);
    } else if (buttonPressed == NotificationActions.agendaNext.key) {
      nextTask = await handler.nextPressed(currentTaskId);
    } else if (buttonPressed == NotificationActions.agendaSkip.key) {
      await handler.skipPressed();
      // To be handled
    }

    store.close();

    if (nextTask.task == null) {
      _log('No next task present');
      await removeNotificationsById(IdHandler.agendaNotificationId);
      return;
    }

    await showAgendaNotification(task: nextTask.task!, isLast: nextTask.isLast);
  }

  // -----------------------------------------
  // ----- HELPERS ----------------------------------
  // -----------------------------------------

  /// Get future to Objectbox Store instance
  ///
  /// If store is already open (in case app is active), attachs to that
  /// instance, or returns a new instance.
  @pragma('vm:entry-point')
  static Future<Store> _getObjectboxStore() async {
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
