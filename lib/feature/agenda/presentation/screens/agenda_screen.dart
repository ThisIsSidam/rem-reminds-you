import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
      body: ListView.separated(
        itemCount: agendas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (BuildContext context, int index) {
          final Agenda agenda = agendas[index];
          return AgendaWidget(agenda: agenda);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAgendaTaskSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
