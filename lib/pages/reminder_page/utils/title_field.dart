import 'package:Rem/pages/reminder_page/utils/title_parser/title_parser.dart';
import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class TitleField extends ConsumerWidget {

  final titleController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final reminder = ref.read(reminderNotifierProvider);
    titleController.text = reminder.title;

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