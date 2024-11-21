import 'package:Rem/database/UserDB.dart';

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

int generatedNotificationId(int id) {
  return int.parse(id.toString() + DateTime.now().toString());
}
