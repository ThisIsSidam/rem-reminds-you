import 'package:flutter_test/flutter_test.dart';
import 'package:rem/feature/recurrence/data/strategies/daily_strategy.dart';
import 'package:rem/feature/recurrence/data/strategies/monthly_strategy.dart';
import 'package:rem/feature/recurrence/data/strategies/no_recurrence_strategy.dart';
import 'package:rem/feature/recurrence/data/strategies/weekly_strategy.dart';

void main() {
  group('NoRecurrenceStrategy', () {
    final NoRecurrenceStrategy strategy = NoRecurrenceStrategy();
    final DateTime base = DateTime(2026, 3, 23, 10);

    test('occurs on base date regardless of time', () {
      expect(strategy.occursOn(base, base), isTrue);
      expect(
        strategy.occursOn(base, base.add(const Duration(hours: 2))),
        isTrue,
      );
      expect(
        strategy.occursOn(base, base.add(const Duration(days: 1))),
        isFalse,
      );
    });

    test('next returns null', () {
      expect(strategy.next(base), isNull);
    });
  });

  group('DailyStrategy', () {
    final DailyStrategy strategy = DailyStrategy();
    final DateTime base = DateTime(2026, 3, 23, 10);

    test('occurs on next day same time', () {
      expect(
        strategy.occursOn(base, base.add(const Duration(days: 1))),
        isTrue,
      );
    });

    test('occurs on same date different time', () {
      expect(
        strategy.occursOn(base, base.add(const Duration(hours: 1))),
        isTrue,
      );
    });

    test('next advances by one day', () {
      expect(strategy.next(base), base.add(const Duration(days: 1)));
    });
  });

  group('WeeklyStrategy', () {
    final WeeklyStrategy strategy = WeeklyStrategy();
    final DateTime base = DateTime(2026, 3, 23, 10);

    test('occurs on multiples of 7 day', () {
      expect(
        strategy.occursOn(base, base.add(const Duration(days: 7))),
        isTrue,
      );
    });

    test('does not occur on day 6', () {
      expect(
        strategy.occursOn(base, base.add(const Duration(days: 6))),
        isFalse,
      );
    });

    test('next advances by 7 days', () {
      expect(strategy.next(base), base.add(const Duration(days: 7)));
    });
  });

  group('MonthlyStrategy', () {
    final MonthlyStrategy strategy = MonthlyStrategy();

    test('occurs on same day next month when day exists', () {
      final DateTime base = DateTime(2026, 1, 15, 8);
      final DateTime target = DateTime(2026, 2, 15, 8);
      expect(strategy.occursOn(base, target), isTrue);
    });

    test('occurs on last day when base day too large for month', () {
      final DateTime base = DateTime(2026, 1, 31, 8);
      final DateTime target = DateTime(2026, 2, 28, 8);
      expect(strategy.occursOn(base, target), isTrue);
    });

    test('occurs with different time on same target date', () {
      final DateTime base = DateTime(2026, 1, 15, 8);
      final DateTime target = DateTime(2026, 2, 15, 9);
      expect(strategy.occursOn(base, target), isTrue);
    });

    test('next makes an adjusted date for short month', () {
      final DateTime base = DateTime(2026, 1, 31, 8);
      expect(strategy.next(base), DateTime(2026, 2, 28, 8));
    });
  });
}
