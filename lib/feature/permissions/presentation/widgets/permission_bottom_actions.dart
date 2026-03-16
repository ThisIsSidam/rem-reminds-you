import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_ext.dart';
import '../../../../core/services/notification_service/notification_service.dart';
import '../../../../shared/widgets/riverpod/async_widget.dart';
import '../../domain/app_permi_handler.dart';
import '../providers/permission_status_provider.dart';
import '../screens/permissions_screen.dart';

class PermissionBottomActions extends ConsumerStatefulWidget {
  const PermissionBottomActions({
    required this.currentPage,
    required this.onContinue,
    super.key,
  });

  /// The currently shown [PermissionPage].
  final PermissionPage currentPage;

  /// Callback for next action. Only runs after permission is given.
  final VoidCallback onContinue;

  @override
  ConsumerState<PermissionBottomActions> createState() =>
      _PermissionBottomActionsState();
}

class _PermissionBottomActionsState
    extends ConsumerState<PermissionBottomActions> {
  bool _hasRequestedPermission = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual<AsyncValue<bool>>(
      permissionProvider(widget.currentPage),
      (AsyncValue<bool>? previous, AsyncValue<bool> next) {
        final bool granted = next.valueOrNull ?? false;

        if (_hasRequestedPermission && granted) {
          _hasRequestedPermission = false;
          widget.onContinue();
        }
      },
    );
  }

  String get _permissionButtonLabel => switch (widget.currentPage) {
        PermissionPage.notification => 'Allow Permission',
        PermissionPage.alarm => 'Allow Permission',
        PermissionPage.battery => 'Set as Unrestricted',
      };

  /// Request the permission based on [widget.currentPage].
  /// TODO: Changed returned value to Future<bool>.. this would mean, changing
  /// the native calls to return results if possible..
  Future<void> _requestPermission() async {
    switch (widget.currentPage) {
      case PermissionPage.notification:
        await NotificationController.requestNotificationPermission();
      case PermissionPage.alarm:
        await AppPermissionHandler.openAlarmSettings();
      case PermissionPage.battery:
        await AppPermissionHandler.requestIgnoreBatteryOptimization();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<bool> permissionAsync =
        ref.watch(permissionProvider(widget.currentPage));
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
                  widget.onContinue();
                  return;
                }

                _hasRequestedPermission = true;
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
        if (widget.currentPage == PermissionPage.battery)
          FutureBuilder<bool>(
            future: AppPermissionHandler.checkRequiredPermissions(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              final bool allowed = snapshot.hasData && snapshot.data!;
              if (!allowed) {
                return const SizedBox.shrink();
              }

              return TextButton(
                onPressed: widget.onContinue,
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
