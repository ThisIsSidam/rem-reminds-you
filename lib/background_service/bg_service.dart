import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:Rem/consts/consts.dart';
import 'package:Rem/notification/notification.dart';
import 'package:Rem/reminder_class/reminder.dart';

//===========================================================
// This is very badly written code. Please don't judge.
// Might not make sense. I have tried my best to make it 
// readable. 
//===========================================================

@pragma('vm:entry-point')
bool mainIsActive = false;
Map<int, Reminder> reminders = {};
final List<Reminder> activeStatusReminders = [];   
final Map<int, int> repeatNumbers = {};
final ReceivePort receivePort = ReceivePort();


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

@pragma('vm:entry-point')
void onStop(ServiceInstance service) async {
  debugPrint("[BGS onStop] called | ${service.runtimeType}");
  receivePort.close();
  IsolateNameServer.removePortNameMapping(bg_isolate_name);
  await service.stopSelf();
  debugPrint("[BGS onStop] service stopped");
}

@pragma('vm:entry-point')
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
    onStop(service);
  });

  // 
  if (service is AndroidServiceInstance)
  {
    service.setForegroundNotificationInfo(
      title: "On Standby",
      content: "Will disappear automatically if not needed."
    );
  }
  
  startListners(service);

  // Life Section
  final now = DateTime.now();
  final Duration delay = DateTime(now.year, now.month, now.day, now.hour, now.minute + 1)
      .difference(now);
  debugPrint("[BBGGSS] delay: ${delay.inSeconds}");
  Timer.periodic(Duration(seconds: delay.inSeconds), (timerFirst) async {
    bgServicePeriodicWork(service);
    debugPrint("[BGS-tp] Timer Running 1");
    Timer.periodic(Duration(minutes: 1), (timer) {
      bgServicePeriodicWork(service);
      debugPrint("[BGS-tp] Timer Running 2");
    });
    timerFirst.cancel();
  });
}

Future<void> bgServicePeriodicWork(ServiceInstance service) async {
  // debugPrint("[BGS-tp] Service Running");
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) 
      {
        // debugPrint("[BGS-tp] service is in foreground mode");

        updateNotification(service);

        for (final reminder in activeStatusReminders)
        {
          // debugPrint("[timerperiodic] ${reminder.title} ${reminder.reminderStatus}"); // To be removed

          if (reminder.reminderStatus != ReminderStatus.active)
          {
            // debugPrint("[BGS-tp] ${reminder.title} status not active. Shouldn't be here.");
            continue;
          }

          if (!reminder.isTimesUp())
          {
            // debugPrint("[BGS-tp] ${reminder.title} is in future. Shouldn't be here.");
            continue;
          }

          final remId = reminder.id;
          if (remId != null)
          {
            if (repeatNumbers[remId] == null) // Ignore the first time and give value for future 
            {
              repeatNumbers[remId] = 0;
              continue;
            } 
            repeatNumbers[remId] = (repeatNumbers[remId] ?? 0) + 1;
            debugPrint("[BGS-tp] ${reminder.title} ${repeatNumbers[remId]}");
            NotificationController.showNotification(reminder, repeatNumber: repeatNumbers[remId] ?? 0);
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
}

@pragma('vm:entry-point')
Future<bool> stopBackgroundService(
  AndroidServiceInstance service
) async {
  debugPrint("[BGS] Attempting to stop background service");
  final SendPort? mainIsolate = IsolateNameServer.lookupPortByName('main');
  if (mainIsolate == null) {
    debugPrint("[BGS] mainIsolate is null");
    onStop(service);
    return true;
  } else {
    debugPrint("[BGS] mainIsolate found");
    mainIsActive = false;
    mainIsolate.send('ping_from_bgIsolate');
    debugPrint("[BGS] sent ping_from_bgIsolate");

    await Future.delayed(Duration(seconds: 5));
    if (mainIsActive)
    {
      debugPrint("[BGS] mainIsolate is active");
      return false;
    }
    else
    {
      debugPrint("[BGS] mainIsolate is not active");
      onStop(service);
      return true;
    }
  }
}

@pragma('vm:entry-point')
void updateNotification(AndroidServiceInstance service) async{
  debugPrint("[BGS] updateNotification called");
  activeStatusReminders.clear(); // Clear for filling updated ones.
  Reminder nextReminder = newReminder; 
  bool nextReminderFlag = false; 
  
  // Stop service if no reminders
  if(reminders.isNotEmpty)
  {
    // debugPrint("[BGS] Reminders not empty");
    for (final reminder in reminders.values)
    {
      // debugPrint("[BGS] Reminder: ${reminder.title}");
      if (reminder.isTimesUp()) // Stores all active reminders in activeStatusReminders
      {
        if (reminder.reminderStatus == ReminderStatus.active) 
        {
          // debugPrint("[BGS] Reminder is active");
          activeStatusReminders.add(reminder);
        }
        else 
        {
          // debugPrint("[BGS] Reminder is not active");
          continue;
        }
      }
      else // Store only first pending reminder in nextReminder.
      {
        // debugPrint("[BGS] Reminder is not in the past");
        nextReminderFlag = true;
        nextReminder = reminder;
        break; 
      }
    }  
  }
  else
  {
    debugPrint("[BGS] Reminders empty");
  } 

  if (activeStatusReminders.isEmpty && !nextReminderFlag) 
  {
    debugPrint("[BGS] Stopping Service, no upcoming rems.");
    service.setForegroundNotificationInfo(
      title: "On Standby",
      content: "Will disappear automatically if not needed."
    );
    await stopBackgroundService(service);
    return;
  }

  if (!nextReminderFlag)
  {
    // debugPrint("[BGS] No next reminders");
    service.setForegroundNotificationInfo(
      title: "No Next Reminders",
      content: "Finish due reminders or silence them, this notifications will disappear."
    );
  }
  else
  {
    // Updating Notification
    nextReminder.dateAndTime = nextReminder.dateAndTime.subtract(Duration(seconds: 5));
    debugPrint("[BGS] Updating [${nextReminder.getDiffString()}]");
    service.setForegroundNotificationInfo(
      title: "Upcoming Reminder: ${nextReminder.title}",
      content: "${nextReminder.getDiffString()}"
    );
  }
}

@pragma('vm:entry-point')
void startListners(
  ServiceInstance service
) {
  IsolateNameServer.registerPortWithName(receivePort.sendPort, bg_isolate_name);

  // Listening for reminders
  receivePort.listen((dynamic message) {
    debugPrint("[BGS] Message \n\n\n\n\nReceived $message");
    if (message is Map<int, Map<String, dynamic>>) { // Received Reminders from Hive DB

      handleReceivedRemindersData(message);
      if (service is AndroidServiceInstance) updateNotification(service);
    } 
    else if (message is Map<String, String>) // Received update after button click on notification. id and action.
    {
      handleNotificationButtonClickUpdate(message);
      if (service is AndroidServiceInstance) updateNotification(service);
    }
    else if (message is String) // String messages, ping, pong.
    {
      debugPrint("[BGS] Message: $message");
      if (message == 'pong') 
      {
        mainIsActive = true;
        debugPrint("[BGS Listener] mainIsActive: $mainIsActive");
      }
      // else debugPrint("[BGS] Unknown Content $message");
    }
    else {
      // debugPrint("[BGS] Unknown Content $message");
    }
  });
}

@pragma('vm:entry-point')
void handleReceivedRemindersData(Map<int, Map<String, dynamic>> message) {
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

@pragma('vm:entry-point')
void handleNotificationButtonClickUpdate(Map<String, String> message) {
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
}
