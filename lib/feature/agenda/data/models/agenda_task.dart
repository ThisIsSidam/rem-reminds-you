import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/extensions/datetime_ext.dart';
import '../../../recurrence/data/models/recurrence_rule.dart';
import '../entities/agenda_task_entity.dart';

part 'generated/agenda_task.freezed.dart';
part 'generated/agenda_task.g.dart';

/// Model for AgendaTask.
@freezed
sealed class AgendaTask with _$AgendaTask {
  factory AgendaTask({
    required int id,
    required String title,
    required DateTime baseDate,
    required RecurrenceRule recurrenceRule,
    @Default(<DateTime>[]) List<DateTime> completedDates,
  }) = _AgendaTask;

  factory AgendaTask.empty() => AgendaTask(
    id: 0,
    title: '',
    baseDate: DateTime.now().add(const Duration(days: 1)),
    completedDates: <DateTime>[],
    recurrenceRule: RecurrenceRule(),
  );

  const AgendaTask._();

  factory AgendaTask.fromJson(Map<String, dynamic> json) =>
      _$AgendaTaskFromJson(json);

  AgendaTaskEntity get toEntity => AgendaTaskEntity(
    id: id,
    title: title,
    baseDate: baseDate,
    completedDates: completedDates
        .map((DateTime e) => e.millisecondsSinceEpoch)
        .toList(),
    recurrenceRule: recurrenceRule.toString(),
  );

  /// Whether the [date] is marked complete.
  bool isCompleted(DateTime date) => completedDates.any(date.isSameDayAs);
}
