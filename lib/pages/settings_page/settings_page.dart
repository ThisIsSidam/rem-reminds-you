import 'package:Rem/consts/const_colors.dart';
import 'package:Rem/pages/settings_page/utils/new_reminder_settings/new_reminder_section.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        shadowColor: ConstColors.darkGrey,
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
          NewReminderSection()
        ],
      ),
    );
  }

  Widget resetIcon() {
    return IconButton(
      icon: Icon(Icons.refresh),
      onPressed: () {},
    );
  }

}