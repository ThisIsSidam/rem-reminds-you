import 'package:flutter/material.dart';
import '../../../../core/extensions/context_ext.dart';

import '../widgets/agenda_settings/agenda_preferences_section.dart';

class AgendaSettingsScreen extends StatelessWidget {
  const AgendaSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          context.local.settingsAgenda,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: <Widget>[SizedBox(height: 16), AgendaPreferencesSection()],
        ),
      ),
    );
  }
}
