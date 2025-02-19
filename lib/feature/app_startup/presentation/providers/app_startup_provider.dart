import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/local_storage/pending_removals_db.dart';
import '../../../../router/app_routes.dart';
import '../../../home/presentation/providers/reminders_provider.dart';
import '../../../permissions/domain/app_permi_handler.dart';
import 'initial_screen_provider.dart';

part 'app_startup_provider.g.dart';

@riverpod
Future<String?> appStartup(Ref ref) async {
  final bool permissions = await AppPermissionHandler.checkPermissions();
  final List<int> toRemove = await PendingRemovalsDB.clearPendingRemovals();
  await ref.read(remindersProvider.notifier).markAsDone(toRemove);

  if (!permissions) {
    ref.read(initialRouteProvider.notifier).setRoute = AppRoute.permissions;
    return AppRoute.permissions.path;
  }

  ref.read(initialRouteProvider.notifier).setRoute = AppRoute.dashboard;
  return AppRoute.dashboard.path;
}
