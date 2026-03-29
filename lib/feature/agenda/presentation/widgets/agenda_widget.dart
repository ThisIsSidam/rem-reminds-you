import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/context_ext.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../data/models/agenda.dart';
import '../../data/models/agenda_task.dart';
import '../providers/agenda_provider.dart';
import 'agenda_task_sheet.dart';

/// Widget for displaying an agenda for a specific date.
class AgendaWidget extends ConsumerWidget {
  const AgendaWidget({required this.agenda, super.key});

  final Agenda agenda;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String dateStr = _getDateString(agenda.date);

    return InkWell(
      onTap: () => showAgendaTaskSheet(
        context,
        ref,
        task: AgendaTask.empty(dateTime: agenda.date),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.inversePrimary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.inversePrimary.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              dateStr,
              style: context.texts.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (agenda.tasks.isEmpty)
              Text('No tasks for this day.', style: context.texts.bodySmall)
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: agenda.tasks.length,
                onReorder: (int oldIndex, int newIndex) {
                  ref
                      .read(agendaProvider.notifier)
                      .reorderTask(oldIndex, newIndex, agenda.date);
                },
                itemBuilder: (BuildContext context, int index) {
                  final AgendaTask task = agenda.tasks[index];
                  return ListTile(
                    key: ValueKey(task.id),
                    contentPadding: .zero,
                    dense: true,
                    visualDensity: .compact,
                    onTap: () => showAgendaTaskSheet(context, ref, task: task),
                    title: Text(task.title),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ReorderableDragStartListener(
                          index: index,
                          child: const Padding(
                            padding: EdgeInsets.only(right: 8, left: 4),
                            child: Icon(
                              Icons.drag_indicator,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Checkbox(
                          value: task.isCompleted(agenda.date),
                          onChanged: (bool? value) => ref
                              .read(agendaProvider.notifier)
                              .updateCompletion(
                                task,
                                date: agenda.date,
                                value: value ?? false,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _getDateString(DateTime date) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime tomorrow = today.add(const Duration(days: 1));

    if (date.isSameDayAs(today)) {
      return 'Today';
    } else if (date.isSameDayAs(tomorrow)) {
      return 'Tomorrow';
    } else {
      return DateFormat('EEEE, MMM d').format(date);
    }
  }
}
