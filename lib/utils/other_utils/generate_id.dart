import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/UserDB.dart';
import 'package:Rem/reminder_class/reminder.dart';

int generateId(Reminder reminder) {
  final currCount = UserDB.getIndiValue(reminderIDGeneratorCurrentCountKey);

  if (currCount == null) { // In case this is the first time using this.
    UserDB.setIndiValue(reminderIDGeneratorCurrentCountKey, 2);
    return 1;
  }

  UserDB.setIndiValue(reminderIDGeneratorCurrentCountKey, currCount + 1);
  return currCount;
}