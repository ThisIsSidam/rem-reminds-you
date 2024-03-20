import 'dart:isolate';
import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/reminder_class/reminder.dart';

class NotificationController {

  static ReceivedAction? initialAction;
  static void Function()? refreshHomePageCallback;

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

  static void initializeCallback(void Function() func) {
    refreshHomePageCallback = func;
  }

  static Future<void> showNotification(String notifTitle) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0, 
        channelKey: '111',
        title: notifTitle,
        payload: {
          "App name": "Nagger"
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'done', 
          label: 'Done'
        )
      ]
    );
  }

  static Future<bool> scheduleNotification(
    Reminder reminder,
    {int repeatNumber = 0}
  ) async {
    final dateTime = reminder.dateAndTime;
    return await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: (reminder.id ?? reminderNullID) + repeatNumber, 
        channelKey: '111',
        groupKey: reminder.id.toString(),
        title: reminder.title,
        payload: {
          "App name": "Nagger"
        },
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
        year: dateTime.year,
        month: dateTime.month,
        day: dateTime.day,
        hour: dateTime.hour,
        minute: dateTime.minute,
        second: dateTime.second,
        millisecond: dateTime.millisecond
      )
    );
  }

  static Future<void> cancelScheduledNotification(String groupKey) async {
    if (groupKey == "Null")
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
  
    if (receivedAction.buttonKeyPressed == 'done') 
    {
      debugPrint("[onDoneButtonPressed] Running");
      await cancelScheduledNotification(receivedAction.groupKey ?? "Null");
      debugPrint("[onDoneButtonPressed] Schedule Cancelled");

      final SendPort? mainIsolate = IsolateNameServer.lookupPortByName('main');
      debugPrint("[onDoneButtonPressed] mainIsolate connected");
      if (mainIsolate != null) 
      {
        debugPrint("[onDoneButtonPressed] mainIsolate not null");
        final message = {
          'message': 'refreshHomePage',
          'id': int.parse(receivedAction.groupKey ?? "Null")
        };
        debugPrint("[onDoneButtonPressed] Message created");
        mainIsolate.send(message);
        debugPrint("[onDoneButtonPressed] Message Sent");
      }
      else 
      { 
        debugPrint("[onDoneButtonPressed] mainIsolate null");
        await Hive.initFlutter();
        debugPrint("[onDoneButtonPressed] Hive init");

        final db = await Hive.openBox(pendingRemovalsBoxName);
        debugPrint("[onDoneButtonPressed] Box Opened");

        final listo = db.get(pendingRemovalsBoxKey) ?? [];
        
        listo.add(int.parse(receivedAction.groupKey ?? "Null"));
        debugPrint("[onDoneButtonPressed] Added ${receivedAction.groupKey} to remove");

        db.put(pendingRemovalsBoxKey, listo);

        debugPrint("[onDoneButtonPressed] To Remove: $listo");
      }    
    }
    else 
    {
      debugPrint("Unknown action with notification.");
    }
  }
  
}