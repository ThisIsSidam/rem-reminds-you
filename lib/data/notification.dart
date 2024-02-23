import 'dart:isolate';
import 'dart:ui';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:timezone/timezone.dart' as tz;

class NotificationController {
  // final notificationsPlugin = AwesomeNotifications();
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

  Future<bool> scheduleNotification(
    int notifID,
    String notifTitle, 
    DateTime scheduleNotificationDateTime
  ) async {
    return await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notifID, 
        channelKey: '111',
        title: notifTitle,
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
        year: scheduleNotificationDateTime.year,
        month: scheduleNotificationDateTime.month,
        day: scheduleNotificationDateTime.day,
        hour: scheduleNotificationDateTime.hour,
        minute: scheduleNotificationDateTime.minute,
        second: scheduleNotificationDateTime.second,
        millisecond: scheduleNotificationDateTime.millisecond
      )
    );
  }

  Future<void> cancelScheduledNotification(int id) async {
    await AwesomeNotifications().cancel(id);
    print("$id cancelled scheduled notification.");
  }

  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications().setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
  
    if (receivedAction.buttonKeyPressed == 'done') {
      
      final SendPort? mainIsolate = IsolateNameServer.lookupPortByName('main');
      if (mainIsolate != null) 
      {
        final message = {
          'message': 'refreshHomePage',
          'id': receivedAction.id ?? 7
        };
        mainIsolate.send(message);
      }
      else 
      { 
        await Hive.initFlutter();
        await Hive.openBox("pending_removal");

        final db = Hive.box("pending_removal");
        final listo = db.get("PENDING_REMOVAL") ?? [];
        
        listo.add(receivedAction.id ?? 7);
        db.put("PENDING_REMOVAL", listo);

        print("To Remove: $listo");
      }

    }
    else 
    {
      print("Unknown action with notification.");
    }
  }
}