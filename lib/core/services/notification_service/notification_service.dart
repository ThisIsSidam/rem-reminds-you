import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:Rem/core/constants/const_strings.dart';
import 'package:Rem/core/hive/pending_removals_db.dart';
import 'package:Rem/core/models/reminder_model/reminder_model.dart';
import 'package:Rem/feature/reminder_sheet/presentation/helper/reminder_sheet_helper.dart';
import 'package:Rem/main.dart';
import 'package:Rem/shared/utils/generate_id.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../shared/utils/logger/global_logger.dart';
import '../../enums/hive_enums.dart';

class NotificationController {
  static ReceivedAction? initialAction;

  static Future<void> initializeLocalNotifications() async {
    await AndroidAlarmManager.initialize();

    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: '111',
          channelName: 'rem_channel',
          channelDescription: 'Shows Reminder Notification',
        )
      ],
    );

    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);

    gLogger.i('Initialized Notifications');
  }

  static Future<bool> checkNotificationPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

    return isAllowed;
  }

  static Future<bool> scheduleNotification(
    ReminderModel reminder,
  ) async {
    final int id = reminder.id;

    final DateTime scheduledTime = reminder.dateTime;

    gLogger.i('Notification Scheduled | ID: $id | DT : $scheduledTime');

    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      id,
      showNotificationCallback,
      allowWhileIdle: true,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      params: reminder.toJson(),
    );

    return true;
  }

  @pragma('vm:entry-point')
  static Future<void> showNotificationCallback(
      int id, Map<String, dynamic> params) async {
    await initLogger();
    gLogger.i('Notification Callback Running | callBackId: $id');

    final Map<String, String> strParams = params.cast<String, String>();
    final ReminderModel reminder = ReminderModel.fromJson(strParams);

    // Should be different each time so that different notifications are shown.
    int notificationId = generatedNotificationId(id);

    gLogger.i('Showing notification | notificationID: $notificationId');

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: notificationId,
          channelKey: '111',
          title: "Reminder: ${reminder.title}",
          groupKey: reminder.id.toString(),
          wakeUpScreen: true,
          payload: reminder.toJson()),
      actionButtons: <NotificationActionButton>[
        NotificationActionButton(
          key: 'done',
          label: 'Done',
          actionType: ActionType.SilentBackgroundAction,
        )
      ],
    );

    // Handle recurring notifications
    if (reminder.autoSnoozeInterval == null) {
      gLogger.i(
        'AutoSnoozeInterval Null | ID : ${reminder.id} | DT : ${reminder.dateTime}',
      );
      return;
    }

    DateTime nextScheduledTime =
        reminder.dateTime.add(reminder.autoSnoozeInterval!);
    reminder.dateTime = nextScheduledTime;
    scheduleNotification(reminder);
    gLogger.i(
      'Scheduled Next Notification | ID : ${reminder.id} | DT : ${reminder.dateTime}',
    );
  }

  /// Used to remove notifications present in user's notification space.
  static Future<void> removeNotifications(String? groupKey) async {
    if (groupKey == null) {
      gLogger.w('Received null groupKey in removeNotifications');
      return;
    }

    await AwesomeNotifications().cancelNotificationsByGroupKey(groupKey);
    gLogger.i('Cleared present notifications | gKey : $groupKey');
  }

  /// Cancels the scheduled notification.
  static Future<void> cancelScheduledNotification(String? groupKey) async {
    if (groupKey == null) {
      gLogger.w('Received null groupKey in cancelScheduleNotification');
      return;
    }

    // Cancelling through ALM coz AwesomeN is used to only send notification.
    // It has no hands in scheduling notifications.
    await AndroidAlarmManager.cancel(int.parse(groupKey));
    gLogger.i('Cancelled scheduled notifications | gKey : $groupKey');
  }

  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);

    gLogger.i('Started Listening to notification events');
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    await initLogger();
    gLogger.i(
        'Received notification action | Action : ${receivedAction.actionType}');

    if (receivedAction.actionType == ActionType.Default) {
      final payload = receivedAction.payload;
      if (payload == null) {
        gLogger.e(
            'Received null payload through notification action | gKey : ${receivedAction.groupKey}');
        throw 'Received null payload through notification action | gKey : ${receivedAction.groupKey}';
      } else {
        final context = navigatorKey.currentContext!;
        final ReminderModel reminder = ReminderModel.fromJson(payload);
        gLogger.i(
          'Notification action : Showing bottom sheet | rId : ${reminder.id} | gKey : ${receivedAction.groupKey}',
        );

        ReminderSheetHelper.openSheet(
          context: context,
          reminder: reminder,
        );
        removeNotifications(receivedAction.groupKey);
      }
    }

    SendPort? mainIsolate = IsolateNameServer.lookupPortByName('main');

    bool isMainActive = await isMainIsolateActive();

    if (receivedAction.buttonKeyPressed == 'done') {
      gLogger.i('Notification action | Done Button Pressed');
      cancelScheduledNotification(
          receivedAction.groupKey ?? notificationNullGroupKey);
      if (isMainActive == true) {
        final message = {
          'action': 'done',
          'id': int.parse(receivedAction.groupKey ?? notificationNullGroupKey)
        };
        mainIsolate!.send(message);
        gLogger.i('Sent action message to main isolate | Message : $message');
      } else {
        await Hive.initFlutter();

        await Hive.openBox(HiveBoxNames.pendingRemovals.name);

        if (receivedAction.groupKey == null) {
          gLogger.e(
              'Received null groupKey in onActionReceivedMethod | gKey : ${receivedAction.groupKey}');
          throw 'Received null groupKey in onActionReceivedMethod | gKey : ${receivedAction.groupKey}';
        }
        PendingRemovalsDB.addPendingRemoval(
            int.parse(receivedAction.groupKey!));
        gLogger.i(
            'Added group key to pending removals list: ${receivedAction.groupKey ?? notificationNullGroupKey}');
      }
    }
  }

  @pragma('vm:entry-point')
  static Future<bool> isMainIsolateActive() async {
    gLogger.i('Checking main isolate status');
    final SendPort? mainIsolate = IsolateNameServer.lookupPortByName('main');
    if (mainIsolate != null) {
      final receivePort = ReceivePort();
      IsolateNameServer.registerPortWithName(
          receivePort.sendPort, 'NotificationIsolate');
      mainIsolate.send('ping');
      gLogger.i("Send 'ping' message to check for main isolate's existence.");
      final timeout = Duration(seconds: 3);
      try {
        final pong = await receivePort.first.timeout(timeout);
        if (pong == 'pong') {
          gLogger.i("Message 'pong' received | Main isolate active");
          return true;
        }
      } catch (e) {
        if (e is TimeoutException) {
          gLogger.i(
              "Timeout | 'pong' msg not received | Main Isolate not active.");
          return false;
        }
      } finally {
        receivePort.close();
        IsolateNameServer.removePortNameMapping('NotificationIsolate');
        gLogger.i('Closed notification receivePort');
      }
    }
    gLogger.i('Main Isolate not found');
    return false;
  }
}
