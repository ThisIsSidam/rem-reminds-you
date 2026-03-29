import 'package:objectbox/objectbox.dart';

import '../../../recurrence/data/models/recurrence_rule.dart';
import '../models/agenda_task.dart';

/// Used for ObjectBox storage of [AgendaTask].
@Entity()
class AgendaTaskEntity {
  AgendaTaskEntity({
    required this.id,
    required this.title,
    required this.baseDate,
    required this.completedDates,
    required this.order,
    required this.recurrenceRule,
  });

  int id;
  String title;
  @Property(type: PropertyType.date)
  DateTime baseDate;
  List<int> completedDates;
  int order;
  String recurrenceRule;

  /// Converts this entity to the corresponding model.
  AgendaTask get toModel {
    return AgendaTask(
      id: id,
      title: title,
      baseDate: baseDate,
      completedDates: completedDates
          .map(DateTime.fromMillisecondsSinceEpoch)
          .toList(),
      order: order,
      recurrenceRule: RecurrenceRule.fromString(recurrenceRule),
    );
  }

  AgendaTaskEntity copyWith({List<int>? completedDates}) {
    return AgendaTaskEntity(
      id: id,
      title: title,
      baseDate: baseDate,
      completedDates: completedDates ?? this.completedDates,
      order: order,
      recurrenceRule: recurrenceRule,
    );
  }
}
