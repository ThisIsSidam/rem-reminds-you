import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:Rem/main.dart';
import 'package:Rem/pages/reminder_page.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:Rem/consts/consts.dart';
import 'package:Rem/reminder_class/reminder.dart';

class NotificationController {

  static ReceivedAction? initialAction;

  static Future<void> initializeLocalNotifications() async {
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

  static Future<void> showNotification(
    Reminder reminder,
    {int repeatNumber = 0}
  ) async {
    await AwesomeNotifications().createNotification(
content: NotificationContent(
        id: (reminder.id ?? reminderNullID) + repeatNumber, 
        channelKey: '111',
        groupKey: reminder.id.toString(),
        title: "Reminder: ${reminder.title}",
        payload: reminder.toMap(),
        autoDismissible: false
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'done', 
          label: 'Done',
          actionType: ActionType.SilentBackgroundAction
        ),
      ],
    );
  }

  static Future<bool> scheduleNotification(
    Reminder reminder,
    {
    int repeatNumber = 0
    }
  ) async {

    final recurringInterval = reminder.recurringInterval;
    final dateTime = reminder.dateAndTime;

    return await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: (reminder.id ?? reminderNullID) + repeatNumber, 
        channelKey: '111',
        groupKey: reminder.id.toString(),
        title: "Reminder: ${reminder.title}",
        payload: reminder.toMap(),
        autoDismissible: false
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'done', 
          label: 'Done',
          actionType: ActionType.SilentBackgroundAction
        ),
      ],
      schedule: NotificationCalendar(
        weekday: recurringInterval == RecurringInterval.weekly
        ? dateTime.weekday
        : null,
        day: dateTime.day,
        hour: dateTime.hour,
        minute: dateTime.minute,
        second: dateTime.second,
        millisecond: dateTime.millisecond,
        repeats: true
      )
    );
  }

  static Future<void> cancelScheduledNotification(String groupKey) async {
    if (groupKey == notificationNullGroupKey)
    {
      debugPrint("[NotificationController] Null groupkey given to cancel.");
      return;
    }

    await AwesomeNotifications().cancelSchedulesByGroupKey(groupKey);
    debugPrint("$groupKey cancelled scheduled notification.");
  }

  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications().setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {

    if (receivedAction.actionType == ActionType.Default)
    {
      final payload = receivedAction.payload;
      if (payload == null)
      {
        throw "[onActionReceivedMethod] Payload is null";
      }
      else
      {
        Navigator.push(navigatorKey.currentContext!, MaterialPageRoute(
          builder: (context) => ReminderPage(
            thisReminder: Reminder.fromMap(payload),   
          )
        ));
      }
    }

    final SendPort? bgIsolate = IsolateNameServer.lookupPortByName(bg_isolate_name);

    void sendToBgIsolate() { // Only called when main is not active.
      if (bgIsolate != null) 
      {
        final message = {
          'action': receivedAction.buttonKeyPressed,
          'id': receivedAction.groupKey ?? notificationNullGroupKey
        };
        bgIsolate.send(message);
      }
      else 
      {
        debugPrint("[NotificationController] background Isolate is null");
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
      }
      else 
      { 
        await Hive.initFlutter();

        final db = await Hive.openBox(pendingRemovalsBoxName);

        final listo = db.get(pendingRemovalsBoxKey) ?? [];

        listo.add(int.parse(receivedAction.groupKey ?? notificationNullGroupKey));

        db.put(pendingRemovalsBoxKey, listo);
        sendToBgIsolate();
        
      } 
    }
    else 
    {
      debugPrint("[NotificationController] Action on notificatino: ${receivedAction.actionType}");
    }
  }

  @pragma('vm:entry-point')
  static Future<bool> isMainIsolateActive() async {
    final SendPort? mainIsolate = IsolateNameServer.lookupPortByName('main');
    if (mainIsolate != null) 
    {
      final receivePort = ReceivePort();
      IsolateNameServer.registerPortWithName(receivePort.sendPort, 'NotificationIsolate');
      mainIsolate.send('ping');
      final timeout = Duration(seconds: 3);
      try {
        final pong = await receivePort.first.timeout(timeout);
        if (pong == 'pong') 
        {
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
