import 'package:Rem/notification/notification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppPermissionHandler {
  static const platform = MethodChannel('app_permission_channel');
  
  static Future<bool> checkPermissions() async { 

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

  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final bool isIgnoring = await platform.invokeMethod('isIgnoringBatteryOptimizations');
      return isIgnoring;
    } on PlatformException catch(e) {
      if (kDebugMode) debugPrint('[isIgnoringBatt..] Failed to check battery settings: $e');
      return false;
    }
  } 

  static Future<void> requestIgnoreBatteryOptimization() async {
    try {
      await platform.invokeMethod('requestIgnoreBatteryOptimization');
    } on PlatformException catch(e) {
      if (kDebugMode) debugPrint('[requestIgnoreBatteryOptimization] Failed to request battery settings: $e');
    }
  }
}