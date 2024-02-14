import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  Future<void> setup() async {
    const androidInitializationSetting = AndroidInitializationSettings(
      '@mipmap/ic_launcher'
    );

    const initSettings = InitializationSettings(
      android: androidInitializationSetting
    );

    await notificationsPlugin.initialize(
      initSettings,
    ); 
  }

  notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails('channelId', 'channelName')
    );
  }

  Future scheduleLocalNotification({
    int id = 0,
    String? title,
    String? body,
    required DateTime scheduleNotificationDateTime 
  }) async {

    final location = tz.getLocation('Asia/Kolkata');

    final scheduledDateTime = tz.TZDateTime.from(
      scheduleNotificationDateTime,
      location
    );

    print("Notification id: $id title: $title");
    return notificationsPlugin.zonedSchedule(
      id, 
      title, 
      body,
      scheduledDateTime,
      await notificationDetails(),
      uiLocalNotificationDateInterpretation: 
        UILocalNotificationDateInterpretation.absoluteTime
    );
  }

  void cancelScheduledLocalNotification(int id) { 
        print("Notification id: $id");

    notificationsPlugin.cancel(id);
  }

}