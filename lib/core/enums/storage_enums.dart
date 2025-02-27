/// Shared Preferences keys
enum SharedKeys {
  reminderId('REMINDER_ID'),
  appVersion('APP_VERSION'),
  pendingRemovals('PENDING_REMOVAL'),
  ;

  const SharedKeys(this.key);
  final String key;
}
