import 'package:flutter/material.dart';
// import 'package:nagger/utils/reminder_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nagger"),
        backgroundColor: Colors.black26,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/reminder_page');
        }
      ),
    );
  }
}