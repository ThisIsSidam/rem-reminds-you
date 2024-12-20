import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<bool> displayNotificationRationale(BuildContext context) async {
  bool userAuthorized = false;
  await showDialog(
    context: context,
    builder: (BuildContext ctx) {
      ThemeData theme = Theme.of(context);
      return AlertDialog(
        backgroundColor: theme.colorScheme.primaryContainer,
        title: Text(
          'Allow Notifications',
          style: theme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "We can't remind you without notifications. Give us the permission. Pretty please.",
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
            child: Text(
              'Deny',
              style: theme.textTheme.titleMedium,
            ),
          ),
          TextButton(
            onPressed: () async {
              userAuthorized = true;
              Navigator.of(ctx).pop();
            },
            child: Text('Allow', style: theme.textTheme.titleMedium),
          ),
        ],
      );
    },
  );

  return userAuthorized &&
      await AwesomeNotifications().requestPermissionToSendNotifications();
}
