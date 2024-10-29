import 'package:Rem/database/UserDB.dart';
import 'package:Rem/reminder_class/reminder.dart';

int generateId(Reminder reminder) {
  final currCount = UserDB.getNextId();

  if (currCount == null) {
    // In case this is the first time using this.
    UserDB.setID(2);
    return 1;
  }

  UserDB.setID(currCount + 1);
  return currCount;
}
