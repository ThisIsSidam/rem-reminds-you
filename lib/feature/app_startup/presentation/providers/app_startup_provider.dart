import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../permissions/domain/app_permi_handler.dart';
import 'initial_screen_provider.dart';

part 'app_startup_provider.g.dart';

@riverpod
Future<String?> appStartup(Ref ref) async {
  final bool permissions = await AppPermissionHandler.checkPermissions();
  if (!permissions) {
    ref.read(initialScreenNotifierProvider.notifier).setRoute = 'Permissions';
    return 'Permissions';
  }

  ref.read(initialScreenNotifierProvider.notifier).setRoute = 'Home';
  return 'Home';
}
