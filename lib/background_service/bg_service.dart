import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:Rem/reminder_class/extra_methods.dart';
import 'package:Rem/utils/functions/datetime_methods.dart';
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
  receivePort.close();
  IsolateNameServer.removePortNameMapping(bg_isolate_name);
  await service.stopSelf();
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
  final seconds = 60 - DateTime.now().second;

  Timer.periodic(Duration(seconds: seconds, milliseconds: 500), (timerFirst) async {
    bgServicePeriodicWork(service);
    Timer.periodic(Duration(minutes: 1), (timer) {
      bgServicePeriodicWork(service);
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
            if ((repeatNumbers[remId] ?? 0) % reminders[remId]!.notifRepeatInterval.inMinutes == 0)
            {
              NotificationController.showNotification(reminder, repeatNumber: repeatNumbers[remId] ?? 1);
            }
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
  final SendPort? mainIsolate = IsolateNameServer.lookupPortByName('main');
  if (mainIsolate == null) {
    onStop(service);
    return true;
  } else {
    mainIsActive = false;
    mainIsolate.send('ping_from_bgIsolate');

    await Future.delayed(Duration(seconds: 5));
    if (mainIsActive)
    {
      return false;
    }
    else
    {
      onStop(service);
      return true;
    }
  }
}

@pragma('vm:entry-point')
void updateNotification(AndroidServiceInstance service) async{
  activeStatusReminders.clear(); // Clear for filling updated ones.
  Reminder? nextReminder = null;  
  
  // Stop service if no reminders
  if(reminders.isNotEmpty)
  {
    // debugPrint("[BGS] Reminders not empty");
    for (final reminder in sortRemindersByDateTime(reminders.values.toList()))
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
        nextReminder = reminder;
        break; 
      }
    }  
  }


  if (activeStatusReminders.isEmpty && nextReminder == null) 
  {
    service.setForegroundNotificationInfo(
      title: "On Standby",
      content: "Will disappear automatically if not needed."
    );
    Future.delayed(Duration(seconds: 2));
    await stopBackgroundService(service);
    return;
  }

  if (nextReminder == null)
  {
    // debugPrint("[BGS] No next reminders");
    service.setForegroundNotificationInfo(
      title: "One reminder left",
      content: "Finish due reminders, this notification will disappear."
    );
  }
  else
  {
    // Updating Notification
    service.setForegroundNotificationInfo(
      title: "Upcoming Reminder: ${nextReminder.title}",
      content: "${getFormattedDiffString(dateTime: nextReminder.dateAndTime)}"
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
    if (message is Map<int, Map<String, String?>>) { // Received Reminders from Hive DB

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
      if (message == 'pong') 
      {
        mainIsActive = true;
      }
      // else debugPrint("[BGS] Unknown Content $message");
    }
    else {
      // debugPrint("[BGS] Unknown Content $message");
    }
  });
}

@pragma('vm:entry-point')
void handleReceivedRemindersData(Map<int, Map<String, String?>> message) {
  List<Map<String, String?>> messageValues = message.values.toList();
    List<Reminder> listOfReminders = List<Reminder>.generate(
      messageValues.length, (index) => Reminder.fromMap(messageValues[index])
    );

    listOfReminders.sort((a, b) {
      DateTime aDateTime = a.dateAndTime;
      DateTime bDateTime = b.dateAndTime;
      return aDateTime.compareTo(bDateTime);
    });
    reminders = {
      for(final rem in listOfReminders) rem.id ?? reminderNullID : rem
    };
}

@pragma('vm:entry-point')
void handleNotificationButtonClickUpdate(Map<String, String> message) {
  try {
    final id = int.parse(message['id'] ?? reminderNullID.toString());
    final thisReminder = reminders[id];
    final action = message['action'];

    if (thisReminder == null)
    {
      throw "[BGS] Null Reminder";
    }


    if (action == 'done')
    {
      thisReminder.reminderStatus = RemindersStatusExtension.fromString(action!);
      thisReminder.incrementRecurDuration();
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
