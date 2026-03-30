import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/extensions/context_ext.dart';
import '../../../../../../core/services/notification_service/notification_service.dart';
import '../../../../../../shared/utils/misc_methods.dart';
import '../../../providers/settings_provider.dart';

class AgendaPreferencesSection extends ConsumerWidget {
  const AgendaPreferencesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 5),
        Column(children: <Widget>[_buildAgendaTimeTile(context, ref)]),
      ],
    );
  }

  Widget _buildAgendaTimeTile(BuildContext context, WidgetRef ref) {
    final TimeOfDay defaultAgendaTime = ref
        .watch(userSettingsProvider)
        .defaultAgendaTime;
    return ListTile(
      onTap: () async {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: defaultAgendaTime,
        );
        if (pickedTime == null) return;

        await ref.read(userSettingsProvider).setDefaultAgendaTime(pickedTime);

        // Update the schedule
        final agendaDateTime = MiscMethods.getAgendaDateTime(pickedTime);
        await NotificationService.scheduleAgenda(agendaDateTime);
      },
      leading: Icon(Icons.view_agenda, color: context.colors.primary),
      title: Text('When to show Agenda?', style: context.texts.titleMedium),
      subtitle: Text(
        defaultAgendaTime.format(context),
        style: context.texts.bodySmall,
      ),
    );
  }
}
