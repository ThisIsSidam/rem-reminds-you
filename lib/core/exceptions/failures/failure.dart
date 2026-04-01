class Failure implements Exception {
  const Failure(this.message, {this.description});
  final String message;
  final String? description;

  @override
  String toString() => message;
}

class UnknownReminderTypeFailure extends Failure {
  const UnknownReminderTypeFailure(Type reminderType)
    : super('Unknown type of reminder found : $reminderType');
}

class BackupFileNotFoundFailure extends Failure {
  const BackupFileNotFoundFailure() : super('Backup file not found!');
}
