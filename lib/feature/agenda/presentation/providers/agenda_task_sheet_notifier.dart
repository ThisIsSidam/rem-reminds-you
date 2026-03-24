import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/models/recurrence_rule.dart';
import '../../../../core/extensions/datetime_ext.dart';
import '../../../../shared/utils/logger/app_logger.dart';
import '../../data/models/agenda_task.dart';

part 'generated/agenda_task_sheet_notifier.g.dart';

@riverpod
class AgendaTaskSheetNotifier extends _$AgendaTaskSheetNotifier {
  @override
  AgendaTask build() {
    _log('Built');
    return AgendaTask.empty();
  }

  // ========================
  // Update Methods
  // ========================

  set task(AgendaTask task) {
    final AgendaTask old = state;
    state = task;
    _log('Update Task From ID:${old.id} To ID:${state.id}');
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
    _log('Update Task Title: $title');
  }

  void updateDate(DateTime date) {
    state = state.copyWith(baseDate: DateTime(date.year, date.month, date.day));
    _log('Update Task DateTime: ${date.friendly()}');
  }

  void updateRecurrence(RecurrenceRule rule) {
    state = state.copyWith(recurrenceRule: rule);
    _log('Update Task Recurrence: ${rule.type}');
  }

  void _log(String msg) => AppLogger.d('[AgendaTaskSheetNotifier] $msg');
}
