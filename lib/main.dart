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
  Map<int, Reminder> reminders = {};

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
      reminders = {
        for(final rem in listOfReminders) rem.id ?? reminderNullID : rem
      };

      debugPrint("[BGS] $reminders");

    } 
    else if (message is Map<String, String>)
    {
      debugPrint("[BGS] Received a Mapstrstr");
      try {
        final id = int.parse(message['id'] ?? reminderNullID.toString());
        final thisReminder = reminders[id];
        final action = message['action'];

        if (thisReminder == null)
        {
          throw "[BGS] Null Reminder";
        }

        debugPrint("[actionReceiver] id: $id action: $action");

        if (action == 'done') thisReminder.reminderStatus = ReminderStatus.done;
        else if (action == 'silence') thisReminder.reminderStatus = ReminderStatus.silenced;
        else throw "[BGS] unknown action given";

        reminders[id] = thisReminder;
      }
      catch(e)
      {
        debugPrint(e.toString());
      }
    }
    else {
      debugPrint("[BGS] Unknown Content $message");
    }
  });

  final List<Reminder> overdueList = [];   
  final Map<int, int> repeatNumbers = {};

  // Update Notification
  void updateNotification(AndroidServiceInstance service) {
    overdueList.clear(); // Clear for filling updated ones.
    
    // Stop service if no reminders
    if (reminders.isEmpty) 
    {
      debugPrint("[BGS] empty content");
      // await service.stopSelf();
    }
    else
    {
      Reminder nextReminder = newReminder; 
      bool nextReminderFlag = false; 
      for (final reminder in reminders.values)
      {
        if (reminder.dateAndTime.isBefore(DateTime.now())) overdueList.add(reminder);
        else 
        {
          nextReminderFlag = true;
          nextReminder = reminder;
          break;
        }
      }     

      if (!nextReminderFlag)
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
          content: "${nextReminder.getDiffString()}"
        );
      }
    }
  }

  // Life Section
  Timer.periodic(const Duration(seconds: 20), (timer) async {
    debugPrint("Service Running");
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) 
      {
        debugPrint("service is in foreground mode");

        updateNotification(service);

        for (final reminder in overdueList)
        {
          debugPrint("[timerperiodic] ${reminder.title} ${reminder.reminderStatus}"); // To be removed

          debugPrint("[BGS] ${reminder.title} ${reminder.reminderStatus}");
          if (reminder.reminderStatus == ReminderStatus.done)
          {
            debugPrint("[BGS-tp] ${reminder.title} -> done");
            break;
          }
          if (reminder.reminderStatus == ReminderStatus.silenced)
          {
            debugPrint("[BGS-tp] ${reminder.title} -> silenced");
            break;
          }
          if (reminder.dateAndTime.isAfter(DateTime.now()))
          {
            debugPrint("[BGS-tp] ${reminder.title} -> Pending, shouldn't be here");
            break;
          }

          final remId = reminder.id;
          if (remId != null)
          {
            NotificationController.showNotification(reminder, repeatNumber: repeatNumbers[remId] ?? 1);
            repeatNumbers[remId] = (repeatNumbers[remId] ?? 0) + 1;
          }
        }
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