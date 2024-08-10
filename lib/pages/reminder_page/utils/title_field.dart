import 'package:Rem/pages/reminder_page/utils/title_parser/title_parser.dart';
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
    final titleParser = TitleParseHandler(ref: ref);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
        ),
        controller: titleController,
        autofocus: true,
        onChanged: (str) {
          titleParser.parse(str);
        }
      ),
    );
  }
}