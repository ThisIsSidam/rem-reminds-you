import 'package:hive_flutter/hive_flutter.dart';

mixin Repeat {
  @HiveField(4)
  Duration notifRepeatInterval = Duration(minutes: 5);

  void initRepeatInterval(Duration interval) {
    this.notifRepeatInterval = interval;
  }
}
