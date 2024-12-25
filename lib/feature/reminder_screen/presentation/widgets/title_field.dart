import 'package:Rem/core/constants/const_strings.dart';
import 'package:Rem/feature/reminder_screen/presentation/providers/central_widget_provider.dart';
import 'package:Rem/feature/reminder_screen/presentation/providers/sheet_reminder_notifier.dart';
import 'package:Rem/feature/reminder_screen/presentation/widgets/title_parser/title_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TitleField extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noRush = ref.watch(sheetReminderNotifier.select((p) => p.noRush));
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

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (noRush)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                'No Rush',
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontStyle: FontStyle.italic,
                ),

              ),
            ),
          TextField(
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              label: Text('Title'),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: noRush
                        ? theme.colorScheme.onSecondaryContainer
                        : theme.colorScheme.onPrimaryContainer,
                  )),
            ),
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: noRush
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onPrimaryContainer),
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
                ref.read(centralWidgetNotifierProvider.notifier).reset();
              });
            },
          ),
        ],
      ),
    );
  }
}
