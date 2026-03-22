import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../router/app_routes.dart';
import '../../../permissions/domain/app_permi_handler.dart';
import 'initial_screen_provider.dart';

part 'generated/app_startup_provider.g.dart';

/// Handles things to be performs when app starts up.
///
/// - Checks if all required permissions are provided and if not provided,
///   routes user to the permissions screen.
@riverpod
Future<String?> appStartup(Ref ref) async {
  final bool permissions =
      await AppPermissionHandler.checkRequiredPermissions();

  if (!permissions) {
    ref.read(initialRouteProvider.notifier).setRoute = AppRoute.permissions;
    return AppRoute.permissions.path;
  }

  ref.read(initialRouteProvider.notifier).setRoute = AppRoute.dashboard;
  return AppRoute.dashboard.path;
}
