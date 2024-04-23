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

  // Data Retrieval Section
  List<Reminder> reminders = [];

  final ReceivePort receivePort = ReceivePort();
  IsolateNameServer.registerPortWithName(receivePort.sendPort, bg_isolate_name);
  receivePort.listen((dynamic message) {
    debugPrint("[BGS] Message Received");
    if (message is Map<int, Map<String, dynamic>>) {

      List<Map<String, dynamic>> messageValues = message.values.toList();
      List<Reminder> listOfReminders = List<Reminder>.generate(
        messageValues.length, (index) => Reminder.fromMap(messageValues[index])
      );

      listOfReminders.sort((a, b) {
        DateTime aDateTime = a.dateAndTime;
        DateTime bDateTime = b.dateAndTime;
        return aDateTime.compareTo(bDateTime);
      });
      for (final rem in listOfReminders)
      {
        debugPrint("[BGS] Reminders : ${rem.title}");
      }
      reminders.clear();
      reminders.addAll(listOfReminders);

      debugPrint("[BGS] $reminders");

    } else {
      debugPrint("[BGS] Unknown Content");
    }
  });

  final List<Reminder> overdueList = [];   

  // Update Notification
  void updateNotification(AndroidServiceInstance service) {
    // Stop service if no reminders
    if (reminders.isEmpty) 
    {
      debugPrint("[BGS] empty content");
      // await service.stopSelf();
    }
    else
    {
      Reminder? nextReminder;  
      for (final reminder in reminders)
      {
        if (reminder.dateAndTime.isBefore(DateTime.now())) overdueList.add(reminder);
        else 
        {
          nextReminder = reminder;
          break;
        }
      }     

      if (nextReminder == null)
      {
        service.setForegroundNotificationInfo(
          title: "No Next Reminders",
          content: "Finish due reminders or silence them, this notifications will disappear."
        );
      }
      else
      {
        // Updating Notification
        service.setForegroundNotificationInfo(
          title: "Upcoming Reminder: ${nextReminder.title}",
          content: "${nextReminder.dateAndTime}"
        );
      }
    }
  }

  // Life Section
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    debugPrint("Service Running");
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) 
      {
        debugPrint("service is in foreground mode");

        updateNotification(service);
        // for (final reminder in overdueList)
        // {
        //   if (reminder.)
        // }
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


