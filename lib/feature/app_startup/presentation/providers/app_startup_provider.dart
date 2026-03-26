import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../router/app_routes.dart';
import '../../../permissions/domain/app_permi_handler.dart';

part 'generated/app_startup_provider.g.dart';

/// Handles things to be performs when app starts up.
///
/// - Checks if all required permissions are provided and if not provided,
///   routes user to the permissions screen.
@riverpod
Future<AppRoute> appStartup(Ref ref) async {
  final bool permissions =
      await AppPermissionHandler.checkRequiredPermissions();

  if (!permissions) {
    return AppRoute.permissions;
  }

  return AppRoute.dashboard;
}
