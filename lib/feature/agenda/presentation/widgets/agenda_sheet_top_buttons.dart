import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../recurrence/data/models/recurrence_rule.dart';
import '../../../recurrence/presentation/widgets/recurrence_rule_sheet.dart';
import '../../data/models/agenda_task.dart';
import '../providers/agenda_provider.dart';
import '../providers/agenda_task_sheet_notifier.dart';

class AgendaSheetTopButtons extends ConsumerWidget {
  const AgendaSheetTopButtons({super.key});

  Future<void> deleteTask(int id, BuildContext context, WidgetRef ref) async {
    ref.read(agendaProvider.notifier).deleteTask(id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? id = ref.watch(
      agendaTaskSheetProvider.select((AgendaTask t) => t.id),
    );
    final RecurrenceRule rule = ref.watch(
      agendaTaskSheetProvider.select((AgendaTask t) => t.recurrenceRule),
    );

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (id != null)
            _buildButton(
              context: context,
              icon: Icons.delete,
              fillColor: Theme.of(context).colorScheme.errorContainer,
              onTap: () => deleteTask(id, context, ref),
            ),

          const Spacer(),
          _buildButton(
            context: context,
            icon: Icons.event_repeat,
            onTap: () async {
              final RecurrenceRule? recurrenceRule = await pickRecurrenceRule(
                context,
                selected: rule,
              );
              if (recurrenceRule == null) return;
              ref
                  .read(agendaTaskSheetProvider.notifier)
                  .updateRecurrence(recurrenceRule);
            },
          ),
        ],
      ),
    );
  }

  IconButton _buildButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    Color? fillColor,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return IconButton.filled(
      constraints: const BoxConstraints(maxWidth: 64),
      icon: Icon(icon, size: 28, color: colorScheme.onPrimaryContainer),
      style: IconButton.styleFrom(
        backgroundColor: fillColor ?? colorScheme.primaryContainer,
        padding: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      onPressed: onTap,
    );
  }
}
