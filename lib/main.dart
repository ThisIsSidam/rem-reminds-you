import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nagger/app.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/database/database.dart';
import 'package:nagger/notification/notification.dart';
import 'package:nagger/reminder_class/duration.g.dart';
import 'package:nagger/reminder_class/reminder.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Hive Database
  await Hive.initFlutter();
  Hive.registerAdapter(DurationAdapter());
  Hive.registerAdapter(ReminderAdapter());
  await Hive.openBox(remindersBoxName);
  
  RemindersDatabaseController.clearPendingRemovals();

  // Awesome Notification
  await NotificationController.initializeLocalNotifications();

  initializeService();

  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(), 
    androidConfiguration: AndroidConfiguration(
      autoStart: true,
      onStart: onStart, 
      isForegroundMode: true
    )
  );

  service.startService();
}

void onStart(ServiceInstance service) async {

  // Flutter SEction
  await Hive.initFlutter();
  Hive.registerAdapter(DurationAdapter());
  Hive.registerAdapter(ReminderAdapter());
  await Hive.openBox(remindersBoxName);


  // Control Section
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  String content = "null";

  final receivePort = ReceivePort();
  IsolateNameServer.registerPortWithName(receivePort.sendPort, "background_service");
  receivePort.listen((message) {

    if (message is! Map<int, Map<String, dynamic>>)
    {
      debugPrint("[BackgroundService] Message not reminder's data");
    }


    debugPrint("[BackgroundService] Message is reminder's data");
    final Map<int, Reminder> reminders = {
      for (var entry in message.entries)
        entry.key: Reminder.fromMap(entry.value),
    };

    debugPrint("[BackgroundService] $reminders");
    final remindersList = reminders.values;

    if (remindersList.isNotEmpty)
    {
      content = remindersList.first.title;
    }
    debugPrint("[BackgroundService] $content");
    
  });

  // Life Section
  Timer.periodic(const Duration(seconds: 10), (timer) async {
    debugPrint("Service Running");
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: "Upcoming Reminder",
          content: "$content"
        );
        debugPrint("service is in foreground mode");
      }
      else
      {
        debugPrint("service is in background mode");
      }
    }
    else 
    {
      debugPrint("Service not AndroidServiceInstance");
    }
  });
}


