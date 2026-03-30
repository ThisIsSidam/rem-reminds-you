import 'package:flutter/material.dart';

import '../widgets/sections/app_preferences_section/app_preferences_section.dart';

class PersonalizationScreen extends StatelessWidget {
  const PersonalizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Personalization',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: <Widget>[SizedBox(height: 16), AppPreferencesSection()],
        ),
      ),
    );
  }
}
