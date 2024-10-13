import 'package:Rem/database/UserDB.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class WhatsNewDialog {

  /// Check if app version stored in UsedDB match with current 
  /// version or not. If not, show the dialog and save the 
  /// current version. 
  static Future<List<Widget>?> checkAndShowWhatsNewDialog(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final String currentVersion = packageInfo.version;
    final String storedVersion = UserDB.getStoredAppVersion() ?? '0.0.0';
    if (currentVersion != storedVersion) {
      UserDB.storeAppVersion(currentVersion);
      return getWhatsNewTileContent(context);
    } else {
      return null;
    }
  }

  static List<Widget> getWhatsNewTileContent(BuildContext context) {
    return <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.red.shade900
          ), 
          child: ListTile(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.warning, color: Colors.white, size: 16,),
                SizedBox(width: 8,),
                Text(
                  'Important!',
                  style: Theme.of(context).textTheme.titleMedium
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
              style: Theme.of(context).textTheme.bodySmall
            ),
          )
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            
            color: Theme.of(context).cardColor
          ), 
          child: ListTile(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.new_releases, color: Colors.white, size: 16,),
                SizedBox(width: 8,),
                Text(
                  'New Stuff',
                  style: Theme.of(context).textTheme.titleMedium
                ),
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
              style: Theme.of(context).textTheme.bodySmall
            ),
          )
        ),
      )
    ];
  }
}