import 'package:hive_flutter/hive_flutter.dart';

mixin PreParsedTitle {
  @HiveField(7)
  String preParsedTitle = '';

  // I plan to move the text parsing methods here.
}
