import 'package:Rem/feature/permissions/domain/app_permi_handler.dart';
import 'package:Rem/shared/widgets/bottom_nav/bottom_nav_bar.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

import '../../../../shared/utils/logger/global_logger.dart';

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

  dispose() {
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
          children: [
            Spacer(),
            _buildNotificationSection(context),
            _buildAlarmPermissionSection(context),
            _buildBatterySection(context),
            Spacer(),
            _buildReturnButton(context)
          ],
        ),
      ),
    );
  }

  Widget _buildReturnButton(BuildContext context) {
    return FutureBuilder(
        future: AppPermissionHandler.checkPermissions(),
        builder: (context, snapshot) {
          return SizedBox(
            height: 72,
            width: double.infinity,
            child: snapshot.hasData
                ? ElevatedButton(
                    onPressed: snapshot.data!
                        ? () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NavigationLayer(),
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      "Let's Go!",
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer),
                  )
                : SizedBox(
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
        });
  }

  Padding _buildNotificationSection(BuildContext context) {
    Future<bool> permissionGiven =
        AwesomeNotifications().isNotificationAllowed();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.notifications_active, color: Colors.white),
            title: Text.rich(TextSpan(children: <InlineSpan>[
              TextSpan(
                  text: 'Notification Permission',
                  style: Theme.of(context).textTheme.titleMedium),
              TextSpan(
                  text: ' (Required)',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontStyle: FontStyle.italic))
            ])),
          ),
          Text(
              'To help you stay organized and never miss an important task,'
              ' we need access to your notifications. This allows us to send you'
              ' timely notifications for your reminders.',
              style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: 16),
          _PermissionButton(
              permission: permissionGiven,
              onPressed: () async {
                gLogger.i('Requesting notification permission');
                await AwesomeNotifications()
                    .requestPermissionToSendNotifications();
              }),
        ],
      ),
    );
  }

  Padding _buildAlarmPermissionSection(BuildContext context) {
    Future<bool> permissionGiven = AppPermissionHandler.checkAlarmPermission();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.alarm, color: Colors.white),
            title: Text.rich(TextSpan(children: <InlineSpan>[
              TextSpan(
                  text: 'Alarms Permission',
                  style: Theme.of(context).textTheme.titleMedium),
              TextSpan(
                  text: ' (Required)',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontStyle: FontStyle.italic))
            ])),
          ),
          Text(
              "To deliver reminders and timely notifications, our app"
              " needs access to your device’s alarms and reminders system."
              " Without this permission, we won't be able to notify you when"
              " reminders are due. This ensures the core functionality"
              " of the app works as intended.",
              style: Theme.of(context).textTheme.bodyMedium),
          SizedBox(height: 16),
          _PermissionButton(
              permission: permissionGiven,
              onPressed: () async {
                gLogger.i('Requesting alarms permissions');
                await AppPermissionHandler.openAlarmSettings();
              }),
        ],
      ),
    );
  }

  Padding _buildBatterySection(BuildContext context) {
    Future<bool> permissionGiven =
        AppPermissionHandler.isIgnoringBatteryOptimizations();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.battery_saver_rounded, color: Colors.white),
            title: Text.rich(TextSpan(children: <InlineSpan>[
              TextSpan(
                  text: 'Battery Permission',
                  style: Theme.of(context).textTheme.titleMedium),
              TextSpan(
                text: ' (Recommended)',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontStyle: FontStyle.italic),
              )
            ])),
            shape: BeveledRectangleBorder(),
          ),
          Text(
            "The device may stop the app from showing you notifications to save power,"
            " it is recommended that you keep the battery optimization unrestricted to"
            " get your reminder notifications whenever you need them.",
            style: Theme.of(context).textTheme.bodyMedium,
            softWrap: true,
          ),
          SizedBox(height: 16),
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
      child: FutureBuilder(
          future: permission,
          builder: (context, snapshot) {
            return ElevatedButton(
                onPressed:
                    snapshot.hasData && snapshot.data! ? null : onPressed,
                child: snapshot.connectionState == ConnectionState.waiting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : snapshot.hasError
                        ? Text(
                            'ERROR',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            snapshot.hasData && snapshot.data!
                                ? 'Done'
                                : deniedLabel,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                          ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: snapshot.hasError
                      ? Theme.of(context).colorScheme.onErrorContainer
                      : Theme.of(context).colorScheme.primaryContainer,
                ));
          }),
    );
  }
}
