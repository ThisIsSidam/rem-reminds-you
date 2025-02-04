import 'package:Rem/core/constants/const_strings.dart';
import 'package:Rem/core/models/recurring_interval/recurring_interval.dart';
import 'package:Rem/feature/reminder_sheet/presentation/providers/central_widget_provider.dart';
import 'package:Rem/feature/reminder_sheet/presentation/providers/sheet_reminder_notifier.dart';
import 'package:Rem/feature/reminder_sheet/presentation/widgets/title_parser/title_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TitleField extends HookConsumerWidget {
  static double _height = 50;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(sheetReminderNotifier);
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
    final Color color = notifier.dateTime.isBefore(DateTime.now())
        ? theme.colorScheme.onErrorContainer
        : notifier.noRush
            ? theme.colorScheme.onSecondaryContainer
            : theme.colorScheme.onTertiaryContainer;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notifier.noRush)
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
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: _height,
                  ),
                  child: TextField(
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      label: Text(
                        'Title',
                        style: theme.textTheme.titleSmall!.copyWith(
                          color: color,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(width: 2, color: color),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: color),
                      ),
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: color),
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
                        ref
                            .read(centralWidgetNotifierProvider.notifier)
                            .reset();
                      });
                    },
                  ),
                ),
              ),
              if (notifier.id != null &&
                  notifier.recurringInterval != RecurringInterval.none)
                PauseButton(height: _height),
            ],
          ),
        ],
      ),
    );
  }
}

class PauseButton extends ConsumerWidget {
  const PauseButton({this.height = 48, super.key});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPaused = ref.watch(sheetReminderNotifier.select((p) => p.isPaused));

    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: () {
          ref.read(sheetReminderNotifier).togglePausedSwitch();
        },
        child: Text(
          isPaused ? 'Resume' : 'Pause',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor:
              Theme.of(context).colorScheme.inversePrimary.withAlpha(100),
          side: BorderSide(
            color: Theme.of(context).colorScheme.inversePrimary.withAlpha(100),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
