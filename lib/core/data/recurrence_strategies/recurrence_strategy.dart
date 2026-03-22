abstract class RecurrenceStrategy {
  bool occursOn(DateTime base, DateTime target);
  DateTime? next(DateTime base);
}
