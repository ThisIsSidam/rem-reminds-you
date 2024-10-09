import 'package:Rem/screens/permissions_screen/utils/app_permi_handler.dart';
import 'package:Rem/widgets/bottom_nav/bottom_nav_bar.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> with WidgetsBindingObserver{

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
      setState((){});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNotificationSection(context),
            _buildAlarmPermissionSection(context),
            _buildReturnButton(context)
          ],
        ),
      )
    );
  }

  Widget _buildReturnButton(BuildContext context) {
    return FutureBuilder(
      future: AppPermissionHandler.checkPermissions(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ElevatedButton(
            onPressed: snapshot.data!
            ? () {
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(
                  builder: (context) => NavigationSection()
                )
              );
            }
            : null,
            child: Text(
              "Let's Go!",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: snapshot.data!
                ? null
                : Colors.grey
              )
            )
          );
        } else {
          return ElevatedButton(
            onPressed: null,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          );
        }
      }
    );
  }

  ListTile _buildNotificationSection(BuildContext context) {

    Future<bool> permissionGiven = AwesomeNotifications().isNotificationAllowed();

    return ListTile(
      title: Text(
        'Notification Permission',
        style: Theme.of(context).textTheme.titleMedium
      ),
      subtitle: Text(
        'Needed to show you notifications',
        style: Theme.of(context).textTheme.bodyMedium
      ),
      trailing: FutureBuilder(
        future: permissionGiven,
        builder: (context, snapshot) {
          return ElevatedButton(
            onPressed: snapshot.hasData 
            ? () async {
              if (snapshot.data!) {
                return null;
              }
              await AwesomeNotifications().requestPermissionToSendNotifications();
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
                style: Theme.of(context).textTheme.bodyMedium
              ), 
            style: ElevatedButton.styleFrom(
              backgroundColor: snapshot.hasError
                ? Colors.red
                : Theme.of(context).primaryColor,
            )
          );
        }
      ),
      shape: BeveledRectangleBorder(),
    );
  }

  ListTile _buildAlarmPermissionSection(BuildContext context) {

    Future<bool> permissionGiven = AppPermissionHandler.checkAlarmPermission();

    return ListTile(
      title: Text(
        'Alarms Permission',
        style: Theme.of(context).textTheme.titleMedium
      ),
      subtitle: Text(
        'Needed to schedule the reminders.',
        style: Theme.of(context).textTheme.bodyMedium
      ),
      trailing: FutureBuilder(
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
                style: Theme.of(context).textTheme.bodyMedium
              ), 
            style: ElevatedButton.styleFrom(
              backgroundColor: snapshot.hasError
                ? Colors.red
                : Theme.of(context).primaryColor,
            )
          );
        }
      ),
      shape: BeveledRectangleBorder(),
    );
  }
}
