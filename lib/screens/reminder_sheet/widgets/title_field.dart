import 'package:Rem/consts/consts.dart';
import 'package:Rem/provider/current_reminder_provider.dart';
import 'package:Rem/screens/reminder_sheet/providers/bottom_element_provider.dart';
import 'package:Rem/screens/reminder_sheet/widgets/title_parser/title_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TitleField extends ConsumerStatefulWidget {
  TitleField({super.key});

  @override
  ConsumerState<TitleField> createState() => _TitleFieldState();
}

class _TitleFieldState extends ConsumerState<TitleField> {
  final titleController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reminder = ref.read(reminderNotifierProvider);
    titleController.text = reminder.preParsedTitle;
    if (titleController.text == reminderNullTitle) {
      titleController.text = "";
    }

    final titleParser = TitleParseHandler(ref: ref);

    // .parse calls the ref.read in the end which then rebuilds.
    // Shouldn't be done in build method. Hence the callback.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      titleParser.parse(titleController.text);
    });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
        ),
        controller: titleController,
        focusNode: _focusNode,
        autofocus: true,
        onChanged: (str) {
          titleParser.parse(str);
        },
        onTap: () {
          // Defer the bottom element removal
          Future.microtask(() {
            ref.read(bottomElementProvider).setAsNone();
          });
        },
      ),
    );
  }
}
