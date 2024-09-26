import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:Rem/consts/consts.dart';
import 'package:Rem/main.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:Rem/screens/reminder_sheet/reminder_sheet.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  }

  static Future<bool> checkNotificationPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

    return isAllowed;
  }

  static Future<bool> scheduleNotification(
    Reminder reminder,
  ) async {
    final int id = reminder.id ?? reminderNullID;

    final DateTime scheduledTime = reminder.dateAndTime;

    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      id,
      showNotificationCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      params: reminder.toMap(),
    );

    return true;
  }

  @pragma('vm:entry-point')
  static Future<void> showNotificationCallback(
      int id, Map<String, dynamic> params) async {
    final Map<String, String> strParams = params.cast<String, String>();

    final Reminder reminder = Reminder.fromMap(strParams);

    int notificationShown = int.parse(strParams['notification_shown'] ?? "0");

    notificationShown += 1;

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: notificationShown,
            channelKey: '111',
            title: "Reminder: ${reminder.title}",
            groupKey: reminder.id.toString(),
            wakeUpScreen: true,
            payload: reminder.toMap()),
        actionButtons: <NotificationActionButton>[
          NotificationActionButton(
            key: 'done',
            label: 'Done',
            actionType: ActionType.SilentBackgroundAction,
          )
        ]);

    // Handle recurring notifications
    DateTime nextScheduledTime =
        reminder.dateAndTime.add(reminder.notifRepeatInterval);

    reminder.dateAndTime = nextScheduledTime;

    final newParams = reminder.toMap();

    newParams['notification_shown'] = notificationShown.toString();

    await AndroidAlarmManager.oneShotAt(
      nextScheduledTime,
      id,
      showNotificationCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      params: newParams,
    );
  }

  static Future<void> cancelScheduledNotification(String groupKey) async {
    if (groupKey == notificationNullGroupKey) {
      debugPrint("[NotificationController] Null groupkey given to cancel.");
      return;
    }

    await AndroidAlarmManager.cancel(int.parse(groupKey));
    debugPrint("$groupKey cancelled scheduled notification.");
  }

  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {

    debugPrint('[onActionReceivedMethod] Received action: ${receivedAction.actionType}');

    if (receivedAction.actionType == ActionType.Default)
    {
      final payload = receivedAction.payload;
      if (payload == null)
      {
        throw "[onActionReceivedMethod] Payload is null";
      }
      else
      {
        final context = navigatorKey.currentContext!;

        debugPrint('[onActionReceivedMethod] Showing bottom sheet with reminder: $payload');

        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) {
            return ReminderSheet(
              thisReminder: Reminder.fromMap(payload),
            );
          }
        );
        debugPrint('[onActionReceivedMethod] Removing notifications with group key: ${receivedAction.groupKey ?? notificationNullGroupKey}');
        cancelScheduledNotification(receivedAction.groupKey ?? notificationNullGroupKey);
      }
    }

    SendPort? mainIsolate = IsolateNameServer.lookupPortByName('main');

    bool isMainActive = await isMainIsolateActive();

    if (receivedAction.buttonKeyPressed == 'done')
    {
      if (isMainActive == true)
      {
        final message = {
          'action': 'done',
          'id': int.parse(receivedAction.groupKey ?? notificationNullGroupKey)
        };
        mainIsolate!.send(message);
        debugPrint('[onActionReceivedMethod] Sent message to main isolate: $message');
      }
      else
      {
        await Hive.initFlutter();

        final db = await Hive.openBox(pendingRemovalsBoxName);

        final listo = db.get(pendingRemovalsBoxKey) ?? [];

        listo.add(int.parse(receivedAction.groupKey ?? notificationNullGroupKey));

        db.put(pendingRemovalsBoxKey, listo);
        debugPrint('[onActionReceivedMethod] Added group key to pending removals list: ${receivedAction.groupKey ?? notificationNullGroupKey}');
      }
    }
    else
    {
      debugPrint("[onActionReceivedMethod] Action on notificatino: ${receivedAction.actionType}");
    }
  }

  @pragma('vm:entry-point')
  static Future<bool> isMainIsolateActive() async {
    final SendPort? mainIsolate = IsolateNameServer.lookupPortByName('main');
    if (mainIsolate != null) {
      final receivePort = ReceivePort();
      IsolateNameServer.registerPortWithName(
          receivePort.sendPort, 'NotificationIsolate');
      mainIsolate.send('ping');
      final timeout = Duration(seconds: 3);
      try {
        final pong = await receivePort.first.timeout(timeout);
        if (pong == 'pong') {
          return true;
        }
      } catch (e) {
        if (e is TimeoutException) {
          return false;
        }
      } finally {
        receivePort.close();
        IsolateNameServer.removePortNameMapping('NotificationIsolate');
      }
    }
    return false;
  }

}
