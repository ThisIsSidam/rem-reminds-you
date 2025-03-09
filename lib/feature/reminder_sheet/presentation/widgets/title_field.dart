import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/constants/const_strings.dart';
import '../../../../core/data/models/recurring_interval/recurring_interval.dart';
import '../providers/central_widget_provider.dart';
import '../providers/sheet_reminder_notifier.dart';
import 'title_parser/title_parser.dart';

const double kHeight = 50;

class TitleField extends HookConsumerWidget {
  const TitleField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool noRush = ref.watch(
      sheetReminderNotifier.select((SheetReminderNotifier p) => p.noRush),
    );
    final TextEditingController titleController = useTextEditingController();
    final FocusNode focusNode = useFocusNode();

    if (noRush) {
      return NoRushTitleField(
        controller: titleController,
        focusNode: focusNode,
      );
    }
    return NormalTitleField(
      focusNode: focusNode,
      titleController: titleController,
    );
  }
}

class NormalTitleField extends HookConsumerWidget {
  const NormalTitleField({
    required this.titleController,
    required this.focusNode,
    super.key,
  });

  final TextEditingController titleController;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime dateTime = ref.watch(
      sheetReminderNotifier.select((SheetReminderNotifier p) => p.dateTime),
    );

    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(focusNode);
        });
        return null;
      },
      <Object?>[],
    );

    titleController.text = ref.watch(
      sheetReminderNotifier
          .select((SheetReminderNotifier p) => p.preParsedTitle),
    );

    if (titleController.text == reminderNullTitle) {
      titleController.text = '';
    }

    final TitleParseHandler titleParser = TitleParseHandler(ref: ref);

    // .parse calls the ref.read in the end which then rebuilds.
    // Shouldn't be done in build method. Hence the callback.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      titleParser.parse(titleController.text);
    });

    final ThemeData theme = Theme.of(context);
    final Color color = dateTime.isBefore(DateTime.now())
        ? theme.colorScheme.onErrorContainer
        : theme.colorScheme.onTertiaryContainer;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        spacing: 8,
        children: <Widget>[
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: kHeight,
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
                focusNode: focusNode,
                onChanged: (String str) {
                  ref.read(sheetReminderNotifier).updatePreParsedTitle(str);
                  titleParser.parse(str);
                },
                onTap: () {
                  // Defer the bottom element removal
                  Future<void>.microtask(() {
                    ref.read(centralWidgetNotifierProvider.notifier).reset();
                  });
                },
              ),
            ),
          ),
          const PauseButton(height: kHeight),
        ],
      ),
    );
  }
}

class NoRushTitleField extends HookConsumerWidget {
  const NoRushTitleField({
    required this.controller,
    required this.focusNode,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    controller.text = ref.watch(
      sheetReminderNotifier.select((SheetReminderNotifier p) => p.title),
    );

    final ThemeData theme = Theme.of(context);
    final Color color = theme.colorScheme.onSecondaryContainer;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Text(
              'No Rush',
              style: theme.textTheme.titleSmall!.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          TextField(
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              label: Text(
                'Title',
                style: theme.textTheme.titleSmall!.copyWith(
                  color: color,
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
            style:
                Theme.of(context).textTheme.titleMedium!.copyWith(color: color),
            controller: controller,
            focusNode: focusNode,
            onChanged: (String str) {
              ref.read(sheetReminderNotifier).updateTitle(str);
            },
            onTap: () {
              // Defer the bottom element removal
              Future<void>.microtask(() {
                ref.read(centralWidgetNotifierProvider.notifier).reset();
              });
            },
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
    final bool isPaused = ref.watch(
      sheetReminderNotifier.select((SheetReminderNotifier p) => p.isPaused),
    );
    final int? id = ref.watch(
      sheetReminderNotifier.select((SheetReminderNotifier p) => p.id),
    );
    final RecurringInterval interval = ref.watch(
      sheetReminderNotifier.select(
        (SheetReminderNotifier p) => p.recurringInterval,
      ),
    );

    if (id == null || interval.isNone) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: () {
          ref.read(sheetReminderNotifier).togglePausedSwitch();
        },
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
        child: Text(
          isPaused ? 'Resume' : 'Pause',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}
