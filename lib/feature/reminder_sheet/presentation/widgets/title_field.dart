import 'package:Rem/core/constants/const_strings.dart';
import 'package:Rem/feature/reminder_sheet/presentation/providers/bottom_element_provider.dart';
import 'package:Rem/feature/reminder_sheet/presentation/providers/sheet_reminder_notifier.dart';
import 'package:Rem/feature/reminder_sheet/presentation/widgets/title_parser/title_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TitleField extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController titleController = useTextEditingController();
    final _focusNode = useFocusNode();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_focusNode);
      });
      return null;
    }, []);

    titleController.text =
        ref.read(sheetReminderNotifier.select((p) => p.preParsedTitle));

    if (titleController.text == reminderNullTitle) {
      titleController.text = '';
    }

    final titleParser = TitleParseHandler(ref: ref);

    // .parse calls the ref.read in the end which then rebuilds.
    // Shouldn't be done in build method. Hence the callback.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      titleParser.parse(titleController.text);
    });

    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        controller: titleController,
        focusNode: _focusNode,
        autofocus: true,
        onChanged: (str) {
          ref.read(sheetReminderNotifier).updatePreParsedTitle(str);
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
