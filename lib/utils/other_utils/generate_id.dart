import 'package:Rem/consts/consts.dart';
import 'package:Rem/database/indi_values_db.dart';
import 'package:Rem/reminder_class/reminder.dart';

int generateId(Reminder reminder) {
  final currCount = IndiValuesDb.getIndiValue(reminderIDGeneratorCurrentCountKey);

  if (currCount == null) { // In case this is the first time using this.
    IndiValuesDb.setIndiValue(reminderIDGeneratorCurrentCountKey, 2);
    return 1;
  }

  IndiValuesDb.setIndiValue(reminderIDGeneratorCurrentCountKey, currCount + 1);
  return currCount;
}