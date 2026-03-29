import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/notification_service/notification_service.dart';
import '../../../../router/app_routes.dart';
import '../../../../shared/utils/misc_methods.dart';
import '../../../permissions/domain/app_permi_handler.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

part 'generated/app_startup_provider.g.dart';

/// Handles things to be performs when app starts up.
///
/// - Checks if all required permissions are provided and if not provided,
///   routes user to the permissions screen.
@riverpod
Future<AppRoute> appStartup(Ref ref) async {
  // Schedule the next agenda notification
  final agendaTime = ref.read(userSettingsProvider).defaultAgendaTime;
  final agendaDateTime = MiscMethods.getAgendaDateTime(agendaTime);
  await NotificationService.scheduleAgenda(agendaDateTime);

  final bool permissions =
      await AppPermissionHandler.checkRequiredPermissions();

  if (!permissions) {
    return AppRoute.permissions;
  }

  return AppRoute.dashboard;
}
