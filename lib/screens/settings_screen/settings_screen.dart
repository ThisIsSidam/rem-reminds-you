import 'package:Rem/consts/const_colors.dart';
import 'package:Rem/database/UserDB.dart';
import 'package:Rem/screens/settings_screen/widgets/new_reminder_settings/new_reminder_section.dart';
import 'package:Rem/screens/settings_screen/widgets/user_preferences_section/user_pref_settings.dart';
import 'package:flutter/material.dart';

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
            UserPreferenceSection(
              refreshPage: refresh,
            ),
            NewReminderSection(),
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
}