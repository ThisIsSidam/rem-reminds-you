import 'package:Rem/screens/permissions_screen/utils/app_permi_handler.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNotificationSection(context),
            _buildAlarmPermissionSection(context)
          ],
        ),
      )
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
              backgroundColor: snapshot.connectionState == ConnectionState.waiting
              ? Colors.red
              : snapshot.hasError
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
              backgroundColor: snapshot.connectionState == ConnectionState.waiting
              ? Colors.red
              : snapshot.hasError
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
