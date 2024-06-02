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




  // Objects and Variables Section
  bool mainIsActive = false;
  Map<int, Reminder> reminders = {};
  /// Does not include reminders with done and silence status
  final List<Reminder> activeStatusReminders = [];   
  final Map<int, int> repeatNumbers = {};




  // Checks if main is active or not. If not, the background service is stopped.
  Future<void> stopBackgroundService() async {
    debugPrint("[BGS] Attempting to stop background service");
    final SendPort? mainIsolate = IsolateNameServer.lookupPortByName('main');
    if (mainIsolate == null) {
      debugPrint("[BGS] mainIsolate is null");
      await service.stopSelf();
    } else {
      debugPrint("[BGS] mainIsolate found");
      mainIsActive = false;
      mainIsolate.send('ping_from_bgIsolate');
      debugPrint("[BGS] sent ping_from_bgIsolate");

      await Future.delayed(Duration(seconds: 2));
      if (!mainIsActive)
      {
        debugPrint("[BGS] mainIsolate is not active");
        await service.stopSelf();
      }
      else
      {
        debugPrint("[BGS] mainIsolate is active");
      }
    }
  }





  // Update Notification
  /// Reload the overdueList as it is changes with time. 
  /// Also update the permanenet notification shown to the user. 
  void updateNotification(AndroidServiceInstance service) async{
    activeStatusReminders.clear(); // Clear for filling updated ones.
    
    // Stop service if no reminders
    if (reminders.isEmpty) 
    {
      debugPrint("[BGS] empty content");
      service.setForegroundNotificationInfo(
        title: "On Standby",
        content: "Automatically disappear if you don't set any reminders."
      );
      await stopBackgroundService();
    }
    else
    {
      Reminder nextReminder = newReminder; 
      bool nextReminderFlag = false; 
      for (final reminder in reminders.values)
      {
        debugPrint("[BGS] ${reminder.title}");
        if (reminder.isInPast()) // Stores all active reminders in dueStatusReminders
        {
          if (reminder.reminderStatus == ReminderStatus.active) activeStatusReminders.add(reminder);
          else continue;
        }
        else // Store only first pending reminder in nextReminder.
        {
          nextReminderFlag = true;
          nextReminder = reminder;
          break; 
        }
      }   

      if (activeStatusReminders.isEmpty && !nextReminderFlag) 
      {
        debugPrint("[BGS] Stopping Service, no upcoming rems.");
        service.setForegroundNotificationInfo(
          title: "On Standby",
          content: "Will disappear automatically."
        );
        await stopBackgroundService();
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





  // Data Retrieval Section
  final ReceivePort receivePort = ReceivePort();
  IsolateNameServer.registerPortWithName(receivePort.sendPort, bg_isolate_name);
  receivePort.listen((dynamic message) {
    debugPrint("[BGS] Message Received");
    if (message is Map<int, Map<String, dynamic>>) { // Received Reminders from Hive DB

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
      if (service is AndroidServiceInstance) updateNotification(service);
    } 
    else if (message is Map<String, String>) // Received update after button click on notification. id and action.
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

        if (action == 'done' || action == 'silence')
        {
          thisReminder.reminderStatus = RemindersStatusExtension.fromString(action!);
          reminders[id] = thisReminder;
        } 
        else throw "[BGS] unknown action given";

        reminders[id] = thisReminder;
      }
      catch(e)
      {
        debugPrint(e.toString());
      }
      if (service is AndroidServiceInstance) updateNotification(service);
    }
    else if (message is String)
    {
      debugPrint("[BGS] Message: $message");
      debugPrint("[BGS] b4msg mainIsActive: $mainIsActive");
      if (message == 'pong') mainIsActive = true;
      else debugPrint("[BGS] Unknown Content $message");
      debugPrint("[BGS] afterMsg mainIsActive: $mainIsActive");
    }
    else {
      debugPrint("[BGS] Unknown Content $message");
    }
  });





  // Life Section
  Timer.periodic(const Duration(seconds: 20), (timer) async {
    debugPrint("Service Running");
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) 
      {
        debugPrint("service is in foreground mode");

        updateNotification(service);

        for (final reminder in activeStatusReminders)
        {
          debugPrint("[timerperiodic] ${reminder.title} ${reminder.reminderStatus}"); // To be removed

          if (reminder.reminderStatus != ReminderStatus.active)
          {
            debugPrint("[BGS-tp] ${reminder.title} status not active. Shouldn't be here.");
            break;
          }

          if (!reminder.isInPast())
          {
            debugPrint("[BGS-tp] ${reminder.title} is in future. Shouldn't be here.");
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
