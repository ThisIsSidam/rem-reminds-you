import 'package:flutter/services.dart';

import '../../../core/services/notification_service/notification_service.dart';
import '../../../shared/utils/logger/app_logger.dart';

class AppPermissionHandler {
  static const MethodChannel platform = MethodChannel('app_permission_channel');

  static Future<bool> checkRequiredPermissions() async {
    final bool notifPermission =
        await NotificationController.checkNotificationPermissions();
    // if notification permission is not present, no need to check alarm
    if (notifPermission == false) return false;
    return checkAlarmPermission();
  }

  static Future<bool> checkAlarmPermission() async {
    try {
      final dynamic isGranted =
          await platform.invokeMethod('checkAlarmPermission');
      return isGranted is bool && isGranted;
    } on PlatformException catch (e) {
      AppLogger.e('Failed to check Alarm permission', error: e);
      return false;
    }
  }

  static Future<void> openAlarmSettings() async {
    try {
      await platform.invokeMethod('openAlarmSettings');
    } on PlatformException catch (e) {
      AppLogger.e('Failed to open Alarm settings', error: e);
    }
  }

  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final dynamic isIgnoring =
          await platform.invokeMethod('isIgnoringBatteryOptimizations');
      return isIgnoring is bool && isIgnoring;
    } on PlatformException catch (e) {
      AppLogger.e('Failed to check battery settings', error: e);
      return false;
    }
  }

  static Future<void> requestIgnoreBatteryOptimization() async {
    try {
      await platform.invokeMethod('requestIgnoreBatteryOptimization');
    } on PlatformException catch (e) {
      AppLogger.e('Failed to request battery settings', error: e);
    }
  }
}
