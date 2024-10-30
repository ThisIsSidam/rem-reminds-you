import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/archives_database.dart';
import 'package:Rem/reminder_class/field_mixins/reminder_status/status.dart';
import 'package:Rem/reminder_class/reminder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArchivesNotifier extends ChangeNotifier {
  ArchivesNotifier() {
    loadArchivedReminders();
  }

  Map<int, Reminder> _archivedReminders = {};

  Map<int, Reminder> get archivedReminders => _archivedReminders;
  int get archiveCount => _archivedReminders.length;

  Future<void> loadArchivedReminders() async {
    _archivedReminders = ArchivesDatabaseController.getArchivedReminders();
    notifyListeners();
  }

  Future<void> addReminderToArchives(Reminder reminder) async {
    if (reminder.id == reminderNullID) {
      throw "[addReminderToArchives] Reminder id is reminderNullID";
    }

    reminder.reminderStatus = ReminderStatus.archived;
    _archivedReminders[reminder.id] = reminder;
    await ArchivesDatabaseController.updateArchivedReminders(
        _archivedReminders);
    notifyListeners();
  }

  Future<Reminder?> deleteArchivedReminder(int id) async {
    if (id == reminderNullID) {
      throw "[deleteArchivedReminder] Reminder id is reminderNullID";
    }

    if (_archivedReminders.containsKey(id)) {
      final reminder = _archivedReminders.remove(id);
      await ArchivesDatabaseController.updateArchivedReminders(
          _archivedReminders);
      notifyListeners();
      return reminder;
    } else {
      throw "Reminder not found in Archives";
    }
  }

  Future<void> clearAllArchivedReminders() async {
    await ArchivesDatabaseController.removeAllArchivedReminders();
    _archivedReminders.clear();
    notifyListeners();
  }

  Future<String> getBackup() async {
    return ArchivesDatabaseController.getBackup();
  }

  Future<void> restoreBackup(String jsonData) async {
    await ArchivesDatabaseController.restoreBackup(jsonData);
    await loadArchivedReminders();
  }
}

final archivesProvider = ChangeNotifierProvider<ArchivesNotifier>((ref) {
  return ArchivesNotifier();
});
