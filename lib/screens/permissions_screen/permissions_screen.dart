import 'package:Rem/consts/const_colors.dart';
import 'package:Rem/screens/permissions_screen/utils/app_permi_handler.dart';
import 'package:Rem/widgets/bottom_nav/bottom_nav_bar.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

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
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                    builder: (context) => NavigationSection()));
                          }
                        : null,
                    child: Text("Let's Go!",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                                color: snapshot.data!
                                    ? Colors.white
                                    : Colors.grey)),
                    style: Theme.of(context)
                        .elevatedButtonTheme
                        .style!
                        .copyWith(
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(15)))),
                            backgroundColor:
                                snapshot.data != null && snapshot.data!
                                    ? WidgetStatePropertyAll(ConstColors.blue)
                                    : WidgetStatePropertyAll(
                                        ConstColors.lightGreyLessOpacity)))
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
          SizedBox(
            width: double.infinity,
            child: FutureBuilder(
                future: permissionGiven,
                builder: (context, snapshot) {
                  return ElevatedButton(
                      onPressed: snapshot.hasData
                          ? () async {
                              if (snapshot.data!) {
                                return null;
                              }
                              await AwesomeNotifications()
                                  .requestPermissionToSendNotifications();
                            }
                          : null,
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
                                      : 'Allow',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: snapshot.hasError
                            ? Colors.red
                            : snapshot.hasData && snapshot.data!
                                ? ConstColors.lightGreyLessOpacity
                                : Theme.of(context).primaryColor,
                      ));
                }),
          )
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
          SizedBox(
            width: double.infinity,
            child: FutureBuilder(
                future: permissionGiven,
                builder: (context, snapshot) {
                  return ElevatedButton(
                      onPressed: snapshot.hasData
                          ? () async {
                              if (snapshot.data!) {
                                return null;
                              }
                              await AppPermissionHandler.openAlarmSettigs();
                            }
                          : null,
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
                                      : 'Allow',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: snapshot.hasError
                            ? Colors.red
                            : snapshot.hasData && snapshot.data!
                                ? ConstColors.lightGreyLessOpacity
                                : Theme.of(context).primaryColor,
                      ));
                }),
          ),
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
                      .copyWith(fontStyle: FontStyle.italic))
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
          FutureBuilder(
              future: permissionGiven,
              builder: (context, snapshot) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: snapshot.hasData
                          ? () async {
                              if (snapshot.data!) {
                                return null;
                              }
                              await AppPermissionHandler
                                  .requestIgnoreBatteryOptimization();
                            }
                          : null,
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
                                      : 'Set as Unrestricted',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: snapshot.hasError
                            ? Colors.red
                            : snapshot.hasData && snapshot.data!
                                ? ConstColors.lightGreyLessOpacity
                                : Theme.of(context).primaryColor,
                      )),
                );
              })
        ],
      ),
    );
  }
}
