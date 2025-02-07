enum HiveBoxNames {
  reminders('reminders'),
  pendingRemovals('pending_removals'),
  individualValues('indi_values'),
  archives('archives'),
  settings('settings'),
  ;

  const HiveBoxNames(this.name);

  final String name;
}

enum HiveKeys {
  reminderIDGeneratorCurrentCountKey('reminder_id_generator_current_count'),
  remindersBoxKey('REMINDERS'),
  archivesKey('ARCHIVES'),
  ;

  const HiveKeys(this.key);

  final String key;
}

/// Shared Preferences keys
enum SharedKeys {
  reminderId('REMINDER_ID'),
  appVersion('APP_VERSION'),
  pendingRemovals('PENDING_REMOVAL'),
  ;

  const SharedKeys(this.key);
  final String key;
}
