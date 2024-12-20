import 'package:Rem/core/hive/UserDB.dart';

int generateId() {
  final currCount = UserDB.getNextId();

  if (currCount == null) {
    // In case this is the first time using this.
    UserDB.setID(2);
    return 1;
  }

  UserDB.setID(currCount + 1);
  return currCount;
}

@pragma('vm:entry-point')
int generatedNotificationId(int id) {
  final int minutesSinceEpoch = DateTime.now().millisecondsSinceEpoch ~/ 60000;
  final String minutes = minutesSinceEpoch.toString();
  final int len = minutes.length;
  return int.parse(id.toString() + minutes.substring(len - 6));
}
