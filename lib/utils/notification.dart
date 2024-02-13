import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  Future<void> setup() async {
    const androidInitializationSetting = AndroidInitializationSettings(
      'flutter_logo'
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
    notificationsPlugin.cancel(id);
  }

  // void showLocalNotification(String title, String body) {
  //   const androidNotificationDetails = AndroidNotificationDetails(
  //     '0', 
  //     'general'
  //   );

  //   print("showing...........");
  //   const notificationDetails = NotificationDetails(
  //     android: androidNotificationDetails
  //   );

  //   notificationsPlugin.show(0, title, body, notificationDetails);
  // }

}