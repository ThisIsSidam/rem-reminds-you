import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TitleField extends ConsumerStatefulWidget {
  const TitleField({super.key});

  @override
  ConsumerState<TitleField> createState() => _TitleFieldState();
}

class _TitleFieldState extends ConsumerState<TitleField> {

  final titleController = TextEditingController();

  @override
  void initState() {
    final reminderNotifier = ref.read(reminderNotifierProvider);
    titleController.text = reminderNotifier.title;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
        ),
        controller: titleController,
        autofocus: true,
      ),
    );
  }
}