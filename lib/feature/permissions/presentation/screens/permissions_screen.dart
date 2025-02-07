import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import '../../../../shared/utils/logger/global_logger.dart';
import '../../../home/presentation/screens/dashboard_screen.dart';
import '../../domain/app_permi_handler.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      gLogger.i('LifecycleState resumed | Rebuilding permissions screen');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    gLogger.i('Build permissions screen');
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            _buildNotificationSection(context),
            _buildAlarmPermissionSection(context),
            _buildBatterySection(context),
            const Spacer(),
            _buildReturnButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnButton(BuildContext context) {
    return FutureBuilder<bool>(
      future: AppPermissionHandler.checkPermissions(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return SizedBox(
          height: 72,
          width: double.infinity,
          child: snapshot.hasData
              ? ElevatedButton(
                  onPressed: snapshot.data!
                      ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  const DashboardScreen(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Text(
                    "Let's Go!",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                )
              : const SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Padding _buildNotificationSection(BuildContext context) {
    final Future<bool> permissionGiven =
        AwesomeNotifications().isNotificationAllowed();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: <Widget>[
          ListTile(
            leading:
                const Icon(Icons.notifications_active, color: Colors.white),
            title: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: 'Notification Permission',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextSpan(
                    text: ' (Required)',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
          Text(
            'To help you stay organized and never miss an important task,'
            ' we need access to your notifications. This allows us to send you'
            ' timely notifications for your reminders.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _PermissionButton(
            permission: permissionGiven,
            onPressed: () async {
              gLogger.i('Requesting notification permission');
              await AwesomeNotifications()
                  .requestPermissionToSendNotifications();
            },
          ),
        ],
      ),
    );
  }

  Padding _buildAlarmPermissionSection(BuildContext context) {
    final Future<bool> permissionGiven =
        AppPermissionHandler.checkAlarmPermission();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.alarm, color: Colors.white),
            title: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: 'Alarms Permission',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextSpan(
                    text: ' (Required)',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
          Text(
            'To deliver reminders and timely notifications, our app'
            ' needs access to your device’s alarms and reminders system.'
            " Without this permission, we won't be able to notify you when"
            ' reminders are due. This ensures the core functionality'
            ' of the app works as intended.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _PermissionButton(
            permission: permissionGiven,
            onPressed: () async {
              gLogger.i('Requesting alarms permissions');
              await AppPermissionHandler.openAlarmSettings();
            },
          ),
        ],
      ),
    );
  }

  Padding _buildBatterySection(BuildContext context) {
    final Future<bool> permissionGiven =
        AppPermissionHandler.isIgnoringBatteryOptimizations();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: <Widget>[
          ListTile(
            leading:
                const Icon(Icons.battery_saver_rounded, color: Colors.white),
            title: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: 'Battery Permission',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextSpan(
                    text: ' (Recommended)',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            shape: const BeveledRectangleBorder(),
          ),
          Text(
            // ignore: lines_longer_than_80_chars
            'The device may stop the app from showing you notifications to save power,'
            // ignore: lines_longer_than_80_chars
            ' it is recommended that you keep the battery optimization unrestricted to'
            ' get your reminder notifications whenever you need them.',
            style: Theme.of(context).textTheme.bodyMedium,
            softWrap: true,
          ),
          const SizedBox(height: 16),
          _PermissionButton(
            permission: permissionGiven,
            onPressed: () async {
              gLogger.i('Requesting battery permissions');
              await AppPermissionHandler.requestIgnoreBatteryOptimization();
            },
            deniedLabel: 'Set as Unrestricted',
          ),
        ],
      ),
    );
  }
}

class _PermissionButton extends StatelessWidget {
  const _PermissionButton({
    required this.permission,
    required this.onPressed,
    this.deniedLabel = 'Allow',
  });

  final Future<bool> permission;
  final String deniedLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FutureBuilder<bool>(
        future: permission,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          return ElevatedButton(
            onPressed: snapshot.hasData && snapshot.data! ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: snapshot.hasError
                  ? Theme.of(context).colorScheme.onErrorContainer
                  : Theme.of(context).colorScheme.primaryContainer,
            ),
            child: snapshot.connectionState == ConnectionState.waiting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : snapshot.hasError
                    ? const Text(
                        'ERROR',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        snapshot.hasData && snapshot.data!
                            ? 'Done'
                            : deniedLabel,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
          );
        },
      ),
    );
  }
}
