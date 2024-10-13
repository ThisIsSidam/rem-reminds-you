import 'package:Rem/consts/const_colors.dart';
import 'package:Rem/database/UserDB.dart';
import 'package:Rem/screens/settings_screen/sections/backup_restore_section/backup_restore_section.dart';
import 'package:Rem/screens/settings_screen/sections/new_reminder_settings/new_reminder_section.dart';
import 'package:Rem/screens/settings_screen/sections/other_section/other_section.dart';
import 'package:Rem/screens/settings_screen/sections/user_preferences_section/user_pref_settings.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen.SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Settings",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          resetIcon()
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            UserPreferenceSection(),
            NewReminderSection(),
            BackupRestoreSection(),
            OtherSection(), 
            _buildVersionWidget()
          ],
        ),
      ),
    );
  }

  Widget resetIcon() {
    return IconButton(
      icon: Icon(Icons.refresh),
      onPressed: () {

        showDialog(
          context: context, 
          builder: (context) {
            return AlertDialog(
              backgroundColor: ConstColors.darkGrey,
              title: Text(
                'Reset Settings to Default?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {Navigator.pop(context);}, 
                    child: Text("No")
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        UserDB.resetSetting();
                      });
                      Navigator.pop(context);
                    }, 
                    child: Text("Yes")
                  )
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildVersionWidget() {
    final packageInfo = PackageInfo.fromPlatform();
    return Center(
      child: FutureBuilder(
        future: packageInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: 24, width: 24,
              child: const Center(child: CircularProgressIndicator())
            );
          } 
      
          if (snapshot.hasData) {
            return Text(
              "v${snapshot.data!.version}",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.grey
              )
            );
          } 
      
          return SizedBox.shrink();
        }
      ),
    );
  }
}