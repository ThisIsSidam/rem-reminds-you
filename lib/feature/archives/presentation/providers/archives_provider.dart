import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/reminder_model/reminder_model.dart';
import '../../../../shared/utils/logger/global_logger.dart';
import '../../data/hive/archives_db.dart';

class ArchivesNotifier extends ChangeNotifier {
  ArchivesNotifier() {
    gLogger.i('ArchivesNotifier initialized');
    loadArchivedReminders();
  }

  @override
  void dispose() {
    gLogger.i('ArchivesNotifier disposed');
    super.dispose();
  }

  Map<int, ReminderModel> _archivedReminders = <int, ReminderModel>{};

  Map<int, ReminderModel> get archivedReminders => _archivedReminders;
  int get archiveCount => _archivedReminders.length;

  Future<void> loadArchivedReminders() async {
    _archivedReminders = ArchivesDatabaseController.getArchivedReminders();
    notifyListeners();
  }

  Future<void> addReminderToArchives(ReminderModel reminder) async {
    await ArchivesDatabaseController.saveReminder(reminder.id, reminder);
    _archivedReminders = ArchivesDatabaseController.getArchivedReminders();
    gLogger.i('Added Reminder to Archives | ID : ${reminder.id}');

    notifyListeners();
  }

  Future<ReminderModel?> deleteArchivedReminder(int id) async {
    final ReminderModel? reminder = _archivedReminders[id];
    if (reminder == null) {
      gLogger.w('Deletion Failed | Reminder not found in Archives | Id : $id');
      return null;
    }
    await ArchivesDatabaseController.removeReminder(reminder.id);
    _archivedReminders = ArchivesDatabaseController.getArchivedReminders();
    gLogger.i('Deleted Reminder from Archives | ID : $id');

    notifyListeners();
    return reminder;
  }

  Future<void> clearAllArchivedReminders() async {
    await ArchivesDatabaseController.removeAllArchivedReminders();
    _archivedReminders.clear();

    gLogger.i('Cleared Archives | Len : ${_archivedReminders.length}');
    notifyListeners();
  }

  Future<String> getBackup() async {
    final String backup = await ArchivesDatabaseController.getBackup();
    gLogger.i('Created Archives Backup');
    return backup;
  }

  Future<void> restoreBackup(String jsonData) async {
    await ArchivesDatabaseController.restoreBackup(jsonData);
    gLogger.i('Restored Database Backup');
    await loadArchivedReminders();
  }

  Future<bool> isInArchives(int id) async {
    return _archivedReminders.containsKey(id);
  }
}

final ChangeNotifierProvider<ArchivesNotifier> archivesProvider =
    ChangeNotifierProvider<ArchivesNotifier>((Ref<ArchivesNotifier> ref) {
  return ArchivesNotifier();
});
