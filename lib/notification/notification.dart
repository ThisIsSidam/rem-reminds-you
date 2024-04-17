import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nagger/app.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/reminder_class/reminder.dart';

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
        ),
        NotificationActionButton(
          key: 'silence', 
          label: 'Silence'
        )
      ]
    );
  }

  static Future<bool> scheduleNotification(
    Reminder reminder,
    {int repeatNumber = 0}
  ) async {

    final recurringFrequency = reminder.recurringFrequency;
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
        NotificationActionButton(
          key: 'silence', 
          label: 'Silence',
          actionType: ActionType.SilentBackgroundAction
        )
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
      // schedule: NotificationCalendar(
      //   second: dateTime.second,
      //   repeats: true
      // )
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

    if (receivedAction.buttonKeyPressed == 'done') 
    {
      final SendPort? mainIsolate = IsolateNameServer.lookupPortByName('main');
      if (mainIsolate != null) 
      {
        final message = {
          'message': 'refreshHomePage',
          'id': int.parse(receivedAction.groupKey ?? notificationNullGroupKey)
        };
        mainIsolate.send(message);
      }
      else 
      { 
        await Hive.initFlutter();

        final db = await Hive.openBox(pendingRemovalsBoxName);

        final listo = db.get(pendingRemovalsBoxKey) ?? [];
        
        listo.add(int.parse(receivedAction.groupKey ?? notificationNullGroupKey));

        db.put(pendingRemovalsBoxKey, listo);
      }    
    }
    else 
    {
      debugPrint("[NotificationController] Unknown action with notification.");
    }
  }
  
}