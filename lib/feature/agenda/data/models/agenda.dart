import 'package:freezed_annotation/freezed_annotation.dart';

import 'agenda_task.dart';

part 'generated/agenda.freezed.dart';
part 'generated/agenda.g.dart';

/// Model for Agenda, representing tasks for a specific date.
@freezed
sealed class Agenda with _$Agenda {
  factory Agenda({
    required DateTime date,
    required List<AgendaTask> tasks,
  }) = _Agenda;

  factory Agenda.fromJson(Map<String, dynamic> json) => _$AgendaFromJson(json);
}
