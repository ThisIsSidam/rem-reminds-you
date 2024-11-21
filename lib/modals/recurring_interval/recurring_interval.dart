import 'package:hive/hive.dart';

part 'recurring_interval.g.dart';

@HiveType(typeId: 2)
enum RecurringInterval {
  @HiveField(0)
  none,
  @HiveField(1)
  daily,
  @HiveField(2)
  weekly,
  @HiveField(3)
  custom;

  @override
  String toString() {
    switch (this) {
      case none:
        return 'None';
      case daily:
        return 'Daily';
      case weekly:
        return 'Weekly';
      case custom:
        return 'Custom';
    }
  }

  static RecurringInterval fromString(String value) {
    return RecurringInterval.values.firstWhere(
      (interval) => interval.toString().toLowerCase() == value.toLowerCase(),
      orElse: () => RecurringInterval.none,
    );
  }

  static RecurringInterval fromIndex(int value) {
    return RecurringInterval.values[value];
  }
}
