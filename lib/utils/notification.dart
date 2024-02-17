import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  final notificationsPlugin = AwesomeNotifications();
  
  Future<void> setup() async {
    await notificationsPlugin.initialize(
      null,
      [
        NotificationChannel(
          channelKey: '111', 
          channelName: 'rem_channel',
          channelDescription: 'Shows Reminder Notification',
        )
      ]
    ); 
  }

  void showNotification(String notifTitle) {
    notificationsPlugin.createNotification(
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
    return await notificationsPlugin.createNotification(
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
          label: 'Done'
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

  void cancelScheduledNotification(int id) {
    notificationsPlugin.cancel(id);
    print("$id cancelled");
  }

}