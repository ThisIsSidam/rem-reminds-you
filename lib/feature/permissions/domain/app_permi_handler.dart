import 'package:Rem/core/services/notification_service/notification_service.dart';
import 'package:Rem/shared/utils/logger/global_logger.dart';
import 'package:flutter/services.dart';

class AppPermissionHandler {
  static const platform = MethodChannel('app_permission_channel');

  static Future<bool> checkPermissions() async {
    bool notifPermission =
        await NotificationController.checkNotificationPermissions();
    bool alarmPermission = await checkAlarmPermission();
    return notifPermission && alarmPermission;
  }

  static Future<bool> checkAlarmPermission() async {
    try {
      final bool isGranted =
          await platform.invokeMethod('checkAlarmPermission');
      return isGranted;
    } on PlatformException catch (e) {
      gLogger.e('Failed to check Alarm permission', error: e);
      return false;
    }
  }

  static Future<void> openAlarmSettings() async {
    try {
      await platform.invokeMethod('openAlarmSettings');
    } on PlatformException catch (e) {
      gLogger.e('Failed to open Alarm settings', error: e);
    }
  }

  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final bool isIgnoring =
          await platform.invokeMethod('isIgnoringBatteryOptimizations');
      return isIgnoring;
    } on PlatformException catch (e) {
      gLogger.e('Failed to check battery settings', error: e);
      return false;
    }
  }

  static Future<void> requestIgnoreBatteryOptimization() async {
    try {
      await platform.invokeMethod('requestIgnoreBatteryOptimization');
    } on PlatformException catch (e) {
      gLogger.e('Failed to request battery settings', error: e);
    }
  }
}
