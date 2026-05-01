import 'recurrence_rule.dart';

class SelectedDaysRule extends RecurrenceRule {
  const SelectedDaysRule({required this.weekdays});

  factory SelectedDaysRule.fromJson(Map<String, dynamic> json) {
    return SelectedDaysRule(
      weekdays: Set<int>.from(json['weekdays'] as List? ?? []),
    );
  }

  final Set<int> weekdays;

  @override
  int get type => 1501;

  @override
  String get name => 'Selected Days';

  @override
  String get description {
    final selectedDays = days.entries
        .where((entry) => weekdays.contains(entry.key))
        .map((entry) => entry.value)
        .join(', ');

    if (selectedDays.isEmpty) {
      return 'No days selected';
    }

    return 'Repeats on $selectedDays';
  }

  SelectedDaysRule copyWith({Set<int>? weekdays}) =>
      SelectedDaysRule(weekdays: weekdays ?? this.weekdays);

  static const Map<int, String> days = {
    DateTime.monday: 'Mon',
    DateTime.tuesday: 'Tue',
    DateTime.wednesday: 'Wed',
    DateTime.thursday: 'Thu',
    DateTime.friday: 'Fri',
    DateTime.saturday: 'Sat',
    DateTime.sunday: 'Sun',
  };

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'weekdays': weekdays.toList(),
  };
}
