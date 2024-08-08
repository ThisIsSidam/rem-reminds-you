import 'package:Rem/database/UserDB.dart';
import 'package:Rem/database/settings/settings_enum.dart';
import 'package:hive_flutter/hive_flutter.dart';

mixin Repeat {
  @HiveField(4)
  Duration notifRepeatInterval = Duration(seconds: 0); // No significant use of this def value, just given it coz have to.

  void initRepeatInterval(Duration? interval) {
    if (interval == null)
    {
      this.notifRepeatInterval = UserDB.getSetting(SettingOption.RepeatIntervalFieldValue);
    }
    else this.notifRepeatInterval = interval;
  }
}