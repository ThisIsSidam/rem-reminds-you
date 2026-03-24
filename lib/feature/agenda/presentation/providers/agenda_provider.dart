import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/extensions/datetime_ext.dart';
import '../../../../main.dart';
import '../../../../shared/utils/logger/app_logger.dart';
import '../../data/entities/agenda_task_entity.dart';
import '../../data/models/agenda.dart';
import '../../data/models/agenda_task.dart';
import '../../data/repository/agenda_task_repository.dart';

part 'generated/agenda_provider.g.dart';

@riverpod
class AgendaNotifier extends _$AgendaNotifier {
  final AgendaTaskRepository _repo = getIt<AgendaTaskRepository>();

  StreamSubscription<List<AgendaTaskEntity>>? _subscription;

  List<AgendaTask> _allTasks = <AgendaTask>[];

  @override
  List<Agenda> build() {
    _listenToTasks();

    ref.onDispose(() {
      _subscription?.cancel();
      _log('Disposed');
    });

    _log('Built');
    return <Agenda>[];
  }

  void _listenToTasks() {
    _subscription = _repo.getTasksStream().listen((
      List<AgendaTaskEntity> entities,
    ) {
      _allTasks = entities.map((AgendaTaskEntity e) => e.toModel).toList();
      _recomputeAgenda();
    });
  }

  void _recomputeAgenda() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    state = List<Agenda>.generate(3, (int index) {
      final DateTime date = today.add(Duration(days: index));

      return Agenda(date: date, tasks: _repo.getTasksForDate(date, _allTasks));
    });
    _log('Recomputed Agendas and Tasks');
  }

  // ========================
  // CRUD / Actions
  // ========================

  Future<void> addTask(AgendaTask task) async {
    _repo.saveTask(task.toEntity);
    _log('Saved task - ID:${task.id} - Title:${task.title}');
  }

  Future<void> updateCompletion(
    AgendaTask task, {
    required DateTime date,
    required bool value,
  }) async {
    // List to be updated
    final List<DateTime> updatedList = List<DateTime>.from(task.completedDates);

    // Does the date already exist in completed list
    final bool exists = updatedList.any(date.isSameDayAs);

    // If we have to mark complete and it isn't already -> mark complete
    // Else if, remove mark, and is marked -> remove mark
    if (value && !exists) {
      updatedList.add(date.date);
    } else if (!value && exists) {
      updatedList.removeWhere(date.isSameDayAs);
    }

    // Update
    final AgendaTask updated = task.copyWith(completedDates: updatedList);
    _repo.saveTask(updated.toEntity);

    _log(
      'Updated completion- ID:${task.id} - Date:${date.date} - Complete:$value',
    );
  }

  void deleteTask(int id) {
    _repo.removeTask(id);
    _log('Deleted task - ID:$id');
  }

  void refresh() => _recomputeAgenda();

  void _log(String msg) => AppLogger.d('[AgendaNotifier] $msg');
}
