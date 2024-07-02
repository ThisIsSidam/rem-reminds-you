import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:Rem/app.dart';
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

  static Future<void> checkNotificationPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

    if (!isAllowed) {
      // Notification permissions are not allowed, request permissions
      await displayNotificationRationale();
    }
  }

  static Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    BuildContext context = MyApp.navigatorKey.currentContext!;
    await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        ThemeData theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.primaryContainer,
          title: Text(
            'Allow Notifications',
            style: theme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "We can't remind you without notifications. Give us the permission. Pretty please.",
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
              child: Text(
                'Deny',
                style: theme.textTheme.titleMedium,
              ),
            ),
            TextButton(
              onPressed: () async {
                userAuthorized = await AwesomeNotifications().requestPermissionToSendNotifications();
                Navigator.of(ctx).pop();
              },
              child: Text(
                'Allow',
                style: theme.textTheme.titleMedium
              ),
            ),
          ],
        );
      },
    );

    return userAuthorized;
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
        payload: {
          "App name": "Rem"
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
    );
  }

  static Future<bool> scheduleNotification(
    Reminder reminder,
    {
    int repeatNumber = 0
    }
  ) async {

    final recurringFrequency = reminder.recurringFrequency;
    final dateTime = reminder.dateAndTime;

    return await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: (reminder.id ?? reminderNullID) + repeatNumber, 
        channelKey: '111',
        groupKey: reminder.id.toString(),
        title: "Reminder: ${reminder.title}",
        payload: {
          "App name": "Rem"
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
        weekday: recurringFrequency == RecurringFrequency.weekly
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
    debugPrint("[NotificationController] onActionReceivedMethod called");

    final SendPort? bgIsolate = IsolateNameServer.lookupPortByName(bg_isolate_name);
    debugPrint("[NotificationController] bgIsolate: $bgIsolate");

    void sendToBgIsolate() { // Only called when main is not active.
      if (bgIsolate != null) 
      {
        debugPrint("[NotificationController] message sending to bgIsolate");
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
    debugPrint("[NotificationController] mainIsolate: $mainIsolate");

    bool isMainActive = await isMainIsolateActive();

    if (receivedAction.buttonKeyPressed == 'done') 
    {
      if (isMainActive == true) 
      {
        debugPrint("[NotificationController] main is active 3");
        final message = {
          'action': 'done',
          'id': int.parse(receivedAction.groupKey ?? notificationNullGroupKey)
        };
        mainIsolate!.send(message);
      }
      else 
      { 
        debugPrint("[NotificationController] main not active");
        await Hive.initFlutter();

        final db = await Hive.openBox(pendingRemovalsBoxName);
        debugPrint("[NotificationController] pendingRemovalsBox: $db");

        final listo = db.get(pendingRemovalsBoxKey) ?? [];
        debugPrint("[NotificationController] listo: $listo");

        listo.add(int.parse(receivedAction.groupKey ?? notificationNullGroupKey));

        db.put(pendingRemovalsBoxKey, listo);
        sendToBgIsolate();
        
      } 
    }
    else 
    {
      debugPrint("[NotificationController] Unknown action with notification.");
    }
  }

  @pragma('vm:entry-point')
  static Future<bool> isMainIsolateActive() async {
    debugPrint("[NotificationController] isMainIsolateActive called");
    final SendPort? mainIsolate = IsolateNameServer.lookupPortByName('main');
    if (mainIsolate != null) 
    {
      debugPrint("[NotificationController] mainIsolate: $mainIsolate");
      final receivePort = ReceivePort();
      IsolateNameServer.registerPortWithName(receivePort.sendPort, 'NotificationIsolate');
      mainIsolate.send('ping');
      final timeout = Duration(seconds: 3);
      try {
        debugPrint("[NotificationController] awaiting pong");
        final pong = await receivePort.first.timeout(timeout);
        if (pong == 'pong') 
        {
          debugPrint("[NotificationController] received pong");
          debugPrint("[NotificationController] main isolate is active");
          return true;
        }
      } catch (e) {
        if (e is TimeoutException) {
          debugPrint("[NotificationController] timed out waiting for pong");
          debugPrint("[NotificationController] main isolate is not active");
          return false;
        }
      } finally {
        debugPrint("[NotificationController] closing receivePort");
        receivePort.close();
        bool nameRemoved = IsolateNameServer.removePortNameMapping('NotificationIsolate');
        debugPrint("[NotificationController] nameRemoved: $nameRemoved");
      }
    }
    debugPrint("[NotificationController] mainIsolate is null");
    debugPrint("[NotificationController] main isolate is not active");
    return false;
  }



}
