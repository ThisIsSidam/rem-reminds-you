import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/exceptions/failures/failure.dart';
import '../../../../../core/extensions/context_ext.dart';
import '../../../../../core/services/notification_service/notification_service.dart';
import '../../../../../shared/utils/misc_methods.dart';
import '../../../../agenda/presentation/providers/agenda_provider.dart';
import '../../../../reminder/presentation/providers/no_rush_provider.dart';
import '../../../../reminder/presentation/providers/reminders_provider.dart';
import '../../providers/settings_provider.dart';

class RestoreProgressDialog extends ConsumerStatefulWidget {
  const RestoreProgressDialog({required this.archive, super.key});
  final Archive archive;

  @override
  ConsumerState<RestoreProgressDialog> createState() =>
      _RestoreProgressDialogState();
}

class _RestoreProgressDialogState extends ConsumerState<RestoreProgressDialog> {
  late final Future<void> _remindersFuture;
  late final Future<void> _noRushFuture;
  late final Future<void> _agendaFuture;
  late final Future<void> _settingsFuture;
  late final Future<List<void>> _allRestorations;

  @override
  void initState() {
    super.initState();
    _remindersFuture = _restoreItem(
      'reminders_backup.json',
      _loadRemindersFromBackup,
    );
    _noRushFuture = _restoreItem('no_rush_backup.json', _loadNoRushFromBackup);
    _agendaFuture = _restoreItem('agenda_backup.json', _loadAgendaFromBackup);
    _settingsFuture = _restoreItem(
      'settings_backup.json',
      _loadSettingsFromBackup,
    );

    _allRestorations = Future.wait([
      _remindersFuture,
      _noRushFuture,
      _agendaFuture,
      _settingsFuture,
    ]);
  }

  Future<void> _loadRemindersFromBackup(ArchiveFile remindersJsonFile) async {
    final String remindersJsonContent = utf8.decode(
      remindersJsonFile.content as List<int>,
    );
    await ref
        .read(remindersProvider.notifier)
        .restoreBackup(remindersJsonContent);
  }

  /// Loads NoRushReminderModels from the backup file
  Future<void> _loadNoRushFromBackup(ArchiveFile archivesJsonFile) async {
    final String archivesJsonContent = utf8.decode(
      archivesJsonFile.content as List<int>,
    );
    await ref
        .read(noRushRemindersProvider.notifier)
        .restoreBackup(archivesJsonContent);
  }

  Future<void> _loadAgendaFromBackup(ArchiveFile agendaJsonFile) async {
    final String agendaJsonContent = utf8.decode(
      agendaJsonFile.content as List<int>,
    );
    ref.read(agendaProvider.notifier).restoreBackup(agendaJsonContent);
    final TimeOfDay agendaTime = ref
        .read(userSettingsProvider)
        .defaultAgendaTime;
    final DateTime agendaDateTime = MiscMethods.getAgendaDateTime(agendaTime);
    await NotificationService.scheduleAgenda(agendaDateTime);
  }

  Future<void> _loadSettingsFromBackup(ArchiveFile settingsJsonFile) async {
    final String settingsJsonContent = utf8.decode(
      settingsJsonFile.content as List<int>,
    );
    await ref.read(userSettingsProvider).restoreBackup(settingsJsonContent);

    /// Re-Schedule the next agenda, the time may have been updated
    final agendaTime = ref.read(userSettingsProvider).defaultAgendaTime;
    final agendaDateTime = MiscMethods.getAgendaDateTime(agendaTime);
    await NotificationService.scheduleAgenda(agendaDateTime);
  }

  Future<dynamic> _restoreItem(
    String fileName,
    Future<void> Function(ArchiveFile) action,
  ) async {
    final ArchiveFile? archiveFile = widget.archive.findFile(fileName);
    if (archiveFile == null) throw const BackupFileNotFoundFailure();

    return Future.wait([
      Future<void>.delayed(const Duration(milliseconds: 500)),
      action(archiveFile),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.local.settingsRestore),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFutureTile(context.local.remindersTitle, _remindersFuture),
          _buildFutureTile(context.local.settingsRestoreNoRush, _noRushFuture),
          _buildFutureTile(context.local.settingsRestoreAgenda, _agendaFuture),
          _buildFutureTile(context.local.settingsTitle, _settingsFuture),
        ],
      ),
      actions: [
        FutureBuilder(
          future: _allRestorations,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.local.settingsLabelOk),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildFutureTile(String title, Future<void> future) {
    return FutureBuilder<void>(
      future: future,
      builder: (context, snapshot) {
        return ListTile(
          leading: _buildLeading(snapshot),
          title: Text(title),
          subtitle: _buildSubtitle(snapshot),
        );
      },
    );
  }

  Widget _buildLeading(AsyncSnapshot<void> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (snapshot.hasError) {
      return const Icon(Icons.close, color: Colors.red);
    }

    return const Icon(Icons.check, color: Colors.green);
  }

  Widget? _buildSubtitle(AsyncSnapshot<void> snapshot) {
    if (snapshot.hasError) {
      if (snapshot.error is BackupFileNotFoundFailure) {
        return Text(context.local.settingsRestoreNotFound);
      }
      return Text(context.local.settingsRestoreError);
    }
    return null;
  }
}
