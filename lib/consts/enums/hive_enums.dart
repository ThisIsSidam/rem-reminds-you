enum HiveBoxNames {
  reminders('reminders'),
  pendingRemovalsBoxName("pending_removals"),
  individualValues('indi_values'),
  archives('archives'),
  settings('settings'),
  ;

  const HiveBoxNames(this.name);

  final String name;
}

enum HiveKeys {
  reminderIDGeneratorCurrentCountKey("reminder_id_generator_current_count"),
  remindersBoxKey("REMINDERS"),
  pendingRemovalsBoxKey("PENDING_REMOVAL"),
  archivesKey('ARCHIVES'),
  ;

  const HiveKeys(this.key);

  final String key;
}
