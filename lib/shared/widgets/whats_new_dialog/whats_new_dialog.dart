import 'package:Rem/core/hive/UserDB.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../utils/logger/global_logger.dart';

class WhatsNewDialog {
  /// Check if app version stored in UsedDB match with current
  /// version or not. If not, show the dialog and save the
  /// current version.
  static void checkAndShowWhatsNewDialog(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final String currentVersion = packageInfo.version;
    final String storedVersion = UserDB.getStoredAppVersion() ?? '0.0.0';
    if (currentVersion != storedVersion) {
      UserDB.storeAppVersion(currentVersion);
      showWhatsNewDialog(context);
    }
  }

  static void showWhatsNewDialog(BuildContext context) async {
    gLogger.i('Showing what\'s new dialog');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: ListTile(
            leading: Icon(Icons.new_releases_outlined),
            title: Text(
              'What\'s New',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 32),
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: getWhatsNewTileContent(context),
            ),
          ),
        );
      },
    );
  }

  static List<Widget> getWhatsNewTileContent(BuildContext context) {
    return <Widget>[
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: DecoratedBox(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.errorContainer),
            child: ListTile(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning,
                    size: 16,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Important!',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                  ),
                ],
              ),
              subtitle: Text(
                  'Previously, the app used a background service to show you repeated'
                  ' notifications. This has been changed, and now the app uses the android\'s'
                  ' Alarms and Reminders feature. \n\nHence it is recommended that you'
                  ' reinstall the app. This would remove the background service\'s residuals left'
                  ' out even after the update.\n\nAn experimental backup and restore option is present'
                  ' in the settings. You can backup your reminders with it if necessary and restore them '
                  ' after reinstalling.',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer)),
            )),
      ),
      Padding(
        padding: EdgeInsets.all(8),
        child: DecoratedBox(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).cardColor),
            child: ListTile(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.new_releases,
                    size: 16,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text('New Stuff',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              subtitle: Text(
                  '- Use of Android\'s Alarms and Reminders feature for showing repeat notifications\n'
                  '- Swipe Actions\n'
                  '- Text Scaling\n'
                  '- Backup and restore\n'
                  '- Improvements to Title Parsing\n'
                  '- Auto-apply parsed title from next times\n'
                  '- Various minor changes',
                  style: Theme.of(context).textTheme.bodyMedium),
            )),
      )
    ];
  }
}
