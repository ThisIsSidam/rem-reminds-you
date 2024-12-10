import 'package:Rem/database/archives_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reminder_model/reminder_model.dart';
import '../utils/logger/global_logger.dart';

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

  Map<int, ReminderModel> _archivedReminders = {};

  Map<int, ReminderModel> get archivedReminders => _archivedReminders;
  int get archiveCount => _archivedReminders.length;

  Future<void> loadArchivedReminders() async {
    _archivedReminders = ArchivesDatabaseController.getArchivedReminders();
    notifyListeners();
  }

  Future<void> addReminderToArchives(ReminderModel reminder) async {
    ;
    _archivedReminders[reminder.id] = reminder;
    await ArchivesDatabaseController.updateArchivedReminders(
        _archivedReminders);
    gLogger.i('Added Reminder to Archives | ID : ${reminder.id}');

    notifyListeners();
  }

  Future<ReminderModel?> deleteArchivedReminder(int id) async {
    if (_archivedReminders.containsKey(id)) {
      final reminder = _archivedReminders.remove(id);
      await ArchivesDatabaseController.updateArchivedReminders(
          _archivedReminders);
      gLogger.i('Deleted Reminder from Archives | ID : ${id}');

      notifyListeners();
      return reminder;
    } else {
      gLogger.w('Deletion Failed | Reminder not found in Archives | Id : $id');
      return null;
    }
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
    return await _archivedReminders.containsKey(id);
  }
}

final archivesProvider = ChangeNotifierProvider<ArchivesNotifier>((ref) {
  return ArchivesNotifier();
});
