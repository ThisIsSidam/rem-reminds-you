import 'package:Rem/consts/const_colors.dart';
import 'package:Rem/database/UserDB.dart';
import 'package:Rem/pages/settings_page/utils/new_reminder_settings/new_reminder_section.dart';
import 'package:Rem/pages/settings_page/utils/user_preferences_section/user_pref_settings.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          UserPreferenceSection(),
          NewReminderSection(),
        ],
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
}