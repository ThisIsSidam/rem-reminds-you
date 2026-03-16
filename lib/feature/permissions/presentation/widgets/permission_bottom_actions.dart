import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_ext.dart';
import '../../../../core/services/notification_service/notification_service.dart';
import '../../../../shared/widgets/riverpod/async_widget.dart';
import '../../domain/app_permi_handler.dart';
import '../providers/permission_status_provider.dart';
import '../screens/permissions_screen.dart';

class PermissionBottomActions extends ConsumerWidget {
  const PermissionBottomActions({
    required this.currentPage,
    required this.onContinue,
    super.key,
  });

  /// The currently shown [PermissionPage].
  final PermissionPage currentPage;

  /// Callback for next action. Only runs after permission is given.
  final VoidCallback onContinue;

  String get _permissionButtonLabel => switch (currentPage) {
        PermissionPage.notification => 'Allow Permission',
        PermissionPage.alarm => 'Allow Permission',
        PermissionPage.battery => 'Set as Unrestricted',
      };

  /// Request the permission based on [currentPage].
  /// TODO: Changed returned value to Future<bool>.. this would mean, changing
  /// the native calls to return results if possible..
  Future<void> _requestPermission() async {
    switch (currentPage) {
      case PermissionPage.notification:
        await NotificationController.requestNotificationPermission();
      case PermissionPage.alarm:
        await AppPermissionHandler.openAlarmSettings();
      case PermissionPage.battery:
        await AppPermissionHandler.requestIgnoreBatteryOptimization();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<bool> permissionAsync =
        ref.watch(permissionProvider(currentPage));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 72,
          width: double.infinity,
          child: AsyncValueWidget<bool>(
            value: permissionAsync,
            data: (bool hasPermission) => ElevatedButton(
              onPressed: () async {
                if (hasPermission) {
                  onContinue();
                  return;
                }

                await _requestPermission();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primaryContainer,
              ),
              child: Text(
                hasPermission ? 'Continue' : _permissionButtonLabel,
                style: context.texts.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
            ),
            loading: () => ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primaryContainer,
              ),
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primaryContainer,
              ),
              child: Text(
                'Something Went Wrong!',
                style: context.texts.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
        if (currentPage == PermissionPage.battery)
          FutureBuilder<bool>(
            future: AppPermissionHandler.checkRequiredPermissions(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              final bool allowed = snapshot.hasData && snapshot.data!;
              if (!allowed) {
                return const SizedBox.shrink();
              }

              return TextButton(
                onPressed: onContinue,
                child: Text(
                  'Continue to app',
                  style: context.texts.bodyMedium,
                ),
              );
            },
          ),
      ],
    );
  }
}
