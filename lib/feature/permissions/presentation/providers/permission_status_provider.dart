import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/notification_service/notification_service.dart';
import '../../domain/app_permi_handler.dart';
import '../screens/permissions_screen.dart';

part 'generated/permission_status_provider.g.dart';

@riverpod
Future<bool> permission(Ref ref, PermissionPage page) async {
  switch (page) {
    case PermissionPage.notification:
      return NotificationService.checkNotificationPermissions();

    case PermissionPage.alarm:
      return AppPermissionHandler.checkAlarmPermission();

    case PermissionPage.battery:
      return AppPermissionHandler.isIgnoringBatteryOptimizations();
  }
}
