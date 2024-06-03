import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:nagger/consts/consts.dart';
import 'package:nagger/notification/notification.dart';
import 'package:nagger/reminder_class/reminder.dart';

//===========================================================
// This is very badly written code. Please don't judge.
// Also, might not make sense so don't edit anything. 
//===========================================================

bool mainIsActive = false;
Map<int, Reminder> reminders = {};
/// Does not include reminders with done and silence status
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

void onStop(ServiceInstance service) async {
  receivePort.close();
  IsolateNameServer.removePortNameMapping(bg_isolate_name);
  await service.stopSelf();
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
    onStop(service);
  });

  startListners(service);

  // Life Section
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    debugPrint("[BGS-tp] Service Running");
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) 
      {
        debugPrint("[BGS-tp] service is in foreground mode");

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
            repeatNumbers[remId] = (repeatNumbers[remId] ?? 0) + 1;
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
  });
}

Future<void> stopBackgroundService(
  AndroidServiceInstance service
) async {
    debugPrint("[BGS] Attempting to stop background service");
    final SendPort? mainIsolate = IsolateNameServer.lookupPortByName('main');
    if (mainIsolate == null) {
      debugPrint("[BGS] mainIsolate is null");
      onStop(service);
    } else {
      debugPrint("[BGS] mainIsolate found");
      mainIsActive = false;
      mainIsolate.send('ping_from_bgIsolate');
      debugPrint("[BGS] sent ping_from_bgIsolate");

      await Future.delayed(Duration(seconds: 2));
      if (!mainIsActive)
      {
        debugPrint("[BGS] mainIsolate is not active");
        onStop(service);
      }
      else
      {
        debugPrint("[BGS] mainIsolate is active");
      }
    }
  }

void updateNotification(AndroidServiceInstance service) async{
  debugPrint("[BGS] updateNotification called");
  activeStatusReminders.clear(); // Clear for filling updated ones.
  Reminder nextReminder = newReminder; 
  bool nextReminderFlag = false; 
  
  // Stop service if no reminders
  if(reminders.isNotEmpty)
  {
    debugPrint("[BGS] Reminders not empty");
    for (final reminder in reminders.values)
    {
      debugPrint("[BGS] Reminder: ${reminder.title}");
      if (reminder.isInPast()) // Stores all active reminders in dueStatusReminders
      {
        if (reminder.reminderStatus == ReminderStatus.active) 
        {
          debugPrint("[BGS] Reminder is active");
          activeStatusReminders.add(reminder);
        }
        else 
        {
          debugPrint("[BGS] Reminder is not active");
          continue;
        }
      }
      else // Store only first pending reminder in nextReminder.
      {
        debugPrint("[BGS] Reminder is not in the past");
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
      content: "Will disappear automatically."
    );
    await stopBackgroundService(service);
    return;
  }

  if (!nextReminderFlag)
  {
    debugPrint("[BGS] No next reminders");
    service.setForegroundNotificationInfo(
      title: "No Next Reminders",
      content: "Finish due reminders or silence them, this notifications will disappear."
    );
  }
  else
  {
    // Updating Notification
    debugPrint("[BGS] Updating notification");
    service.setForegroundNotificationInfo(
      title: "Upcoming Reminder: ${nextReminder.title}",
      content: "${nextReminder.getDiffString()}"
    );
  }
}

void startListners(
  ServiceInstance service
) {
  IsolateNameServer.registerPortWithName(receivePort.sendPort, bg_isolate_name);

  // Listening for reminders
  receivePort.listen((dynamic message) {
    debugPrint("[BGS] Message Received");
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
      if (message == 'pong') mainIsActive = true;
      else debugPrint("[BGS] Unknown Content $message");
    }
    else {
      debugPrint("[BGS] Unknown Content $message");
    }
  });
}

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
