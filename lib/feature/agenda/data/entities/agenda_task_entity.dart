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

  factory AgendaTaskEntity.fromJson(
    Map<String, dynamic> map, {
    bool asNew = false,
  }) {
    return AgendaTaskEntity(
      id: asNew ? 0 : (map['id'] as int? ?? 0),
      title: map['title'] as String? ?? '',
      baseDate: DateTime.fromMillisecondsSinceEpoch(
        map['baseDate'] as int? ?? 0,
      ),
      completedDates:
          (map['completedDates'] as List<dynamic>?)?.cast<int>() ?? <int>[],
      order: map['order'] as int? ?? 0,
      recurrenceRule: map['recurrenceRule'] as String? ?? '',
    );
  }

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

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'baseDate': baseDate.millisecondsSinceEpoch,
      'completedDates': completedDates,
      'order': order,
      'recurrenceRule': recurrenceRule,
    };
  }
}
