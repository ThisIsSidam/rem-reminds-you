import 'package:flutter/material.dart';
import 'package:nagger/pages/home_page.dart';
import 'package:nagger/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: myTheme
    );
  }
}