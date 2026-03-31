import 'package:flutter/material.dart';

import '../widgets/reminder_settings/gestures_section/gestures_section.dart';
import '../widgets/reminder_settings/new_reminder_settings/new_reminder_section.dart';
import '../widgets/reminder_settings/reminder_preferences_section/reminder_preferences_section.dart';

class ReminderSettingsScreen extends StatelessWidget {
  const ReminderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Reminder Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 16),
            const ReminderPreferencesSection(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
            const GesturesSection(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
            const NewReminderSection(),
            SizedBox(height: MediaQuery.viewPaddingOf(context).bottom + 16),
          ],
        ),
      ),
    );
  }
}
