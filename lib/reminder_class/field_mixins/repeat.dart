import 'package:hive_flutter/hive_flutter.dart';

mixin Repeat {
  @HiveField(4)
  Duration autoSnoozeInterval = Duration(minutes: 5);
}
