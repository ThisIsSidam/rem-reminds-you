import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extensions/context_ext.dart';
import '../../data/models/agenda.dart';
import '../providers/agenda_provider.dart';
import '../widgets/agenda_task_sheet.dart';
import '../widgets/agenda_widget.dart';

/// Screen for displaying the agenda.
class AgendaScreen extends HookConsumerWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Agenda> agendas = ref.watch(agendaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      body: Column(
        mainAxisSize: .min,
        children: [
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: agendas.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int index) {
                final Agenda agenda = agendas[index];
                return AgendaWidget(agenda: agenda);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Tap card to create new task',
              textAlign: .center,
              style: context.texts.bodySmall,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAgendaTaskSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
