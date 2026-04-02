import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/extensions/context_ext.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../shared/widgets/save_close_buttons.dart';
import '../../../../shared/widgets/snack_bar/custom_snack_bar.dart';
import '../../data/models/agenda_task.dart';
import '../providers/agenda_provider.dart';
import '../providers/agenda_task_sheet_notifier.dart';
import 'agenda_sheet_top_buttons.dart';

Future<void> showAgendaTaskSheet(
  BuildContext context,
  WidgetRef ref, {
  AgendaTask? task,
}) {
  if (task != null) {
    ref.read(agendaTaskSheetProvider.notifier).task = task;
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) => ProviderScope(
      overrides: <Override>[
        agendaTaskSheetProvider.overrideWithBuild(
          (_, _) => task ?? AgendaTask.empty(),
        ),
      ],
      child: const AgendaTaskSheet(),
    ),
  );
}

class AgendaTaskSheet extends ConsumerStatefulWidget {
  const AgendaTaskSheet({super.key});

  @override
  ConsumerState<AgendaTaskSheet> createState() => _AgendaTaskSheetState();
}

class _AgendaTaskSheetState extends ConsumerState<AgendaTaskSheet> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double keyboardInsets = MediaQuery.of(context).viewInsets.bottom;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 500 + keyboardInsets + context.bottomPadding,
      ),
      child: SingleChildScrollView(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(bottom: keyboardInsets),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const AgendaSheetTopButtons(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  // Only have bottomPadding for navbar, if
                  // keyboard is not present
                  keyboardInsets > 0 ? 4 : context.bottomPadding,
                ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                  color: theme.colorScheme.surfaceContainer,
                ),
                child: Column(
                  spacing: 8,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: _TitleField(
                        key: ValueKey<String>('agenda-task-sheet-title'),
                      ),
                    ),
                    const _DateChips(
                      key: ValueKey<String>('agenda-task-sheet-date-chips'),
                    ),
                    SaveCloseButtons(
                      onTapClose: () => Navigator.pop(context),
                      onTapSave: () {
                        final AgendaTask task = ref.read(
                          agendaTaskSheetProvider,
                        );
                        if (task.title.isEmpty) {
                          return AppUtils.showToast(
                            msg: context.local.sheetEnterTitleError,
                            type: .error,
                          );
                        }
                        ref.read(agendaProvider.notifier).addTask(task);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleField extends HookConsumerWidget {
  const _TitleField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AgendaTaskSheetNotifier sheetNotifier = ref.read(
      agendaTaskSheetProvider.notifier,
    );
    final String title = ref.read(
      agendaTaskSheetProvider.select((AgendaTask task) => task.title),
    );

    final TextEditingController controller = useTextEditingController(
      text: title,
    );

    final Color color = context.colors.onTertiaryContainer;

    return Row(
      spacing: 8,
      children: <Widget>[
        Expanded(
          child: TextField(
            autofocus: true,
            controller: controller,
            onChanged: sheetNotifier.updateTitle,
            decoration: InputDecoration(
              label: Text(
                context.local.agendaTaskTitle,
                style: context.theme.textTheme.titleSmall!.copyWith(
                  color: color,
                  fontStyle: FontStyle.normal,
                ),
              ),
              hintText: context.local.agendaEnterTaskHint,
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
          ),
        ),
      ],
    );
  }
}

class _DateChips extends ConsumerWidget {
  const _DateChips({super.key});

  DateTime _normalize(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime selectedDate = ref.watch(
      agendaTaskSheetProvider.select((AgendaTask task) => task.baseDate),
    );

    final DateTime today = _normalize(DateTime.now());

    final List<DateTime> dates = List<DateTime>.generate(3, (int i) {
      return today.add(Duration(days: i));
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: dates.map((DateTime date) {
          final bool isSelected = date.isSameDayAs(selectedDate);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_label(context, date)),
              selected: isSelected,
              onSelected: (_) =>
                  ref.read(agendaTaskSheetProvider.notifier).updateDate(date),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(BuildContext context, DateTime date) {
    final DateTime today = DateTime.now();
    if (date.isSameDayAs(today)) return context.local.agendaToday;

    final DateTime tomorrow = today.add(const Duration(days: 1));
    if (date.isSameDayAs(tomorrow)) return context.local.agendaTomorrow;

    return context.local.agendaDayAfter;
  }
}
