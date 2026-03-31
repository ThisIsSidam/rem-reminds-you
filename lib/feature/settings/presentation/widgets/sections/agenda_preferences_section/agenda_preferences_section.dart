import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/services/notification_service/notification_service.dart';
import '../../../../../../shared/utils/misc_methods.dart';
import '../../../providers/settings_provider.dart';
import '../../shared/subtitle_setting_tile.dart';

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
    return SubtitleSettingTile<TimeOfDay>(
      leading: Icons.view_agenda,
      title: 'When to show Agenda?',
      selector: (UserSettingsNotifier p) => p.defaultAgendaTime,
      subtitleBuilder: (BuildContext context, TimeOfDay? value) =>
          value != null ? value.format(context) : '',
      onTap: (BuildContext context, WidgetRef ref, TimeOfDay? value) async {
        if (value == null) return;
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: value,
        );
        if (pickedTime == null) return;

        await ref.read(userSettingsProvider).setDefaultAgendaTime(pickedTime);

        final agendaDateTime = MiscMethods.getAgendaDateTime(pickedTime);
        await NotificationService.scheduleAgenda(agendaDateTime);
      },
    );
  }
}
