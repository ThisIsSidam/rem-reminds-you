import 'package:Rem/notification/notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppPermissionHandler {
  static const platform = MethodChannel('alarm_permission_channel');
  
  static Future<bool> checkPermissions() async { 
    if (kDebugMode) debugPrint('Checking permissions');

    bool notifPermission = await NotificationController.checkNotificationPermissions(); 
    bool alarmPermission = await checkAlarmPermission();
    return notifPermission && alarmPermission;
  }

  static Future<bool> checkAlarmPermission() async {
    try {
      final bool isGranted = await platform.invokeMethod('checkAlarmPermission');
      return isGranted;
    } on PlatformException catch(e) {
      if (kDebugMode) debugPrint('[checkAlarmPermission] Failed to check Alarm permission: ${e.message}');
      return false;
    }
  }

  static Future<void> openAlarmSettigs() async {
    try {
      await platform.invokeMethod('openAlarmSettings');
    } on PlatformException catch(e) {
      if (kDebugMode) debugPrint('[openAlarmSettings] Failed to open Alarm settings: ${e.message}');
    }
  } 
}