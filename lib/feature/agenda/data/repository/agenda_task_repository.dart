import 'package:objectbox/objectbox.dart';

import '../../../../core/data/recurrence_strategies/recurrence_strategy.dart';
import '../../../../core/domain/recurrence_factory.dart';
import '../entities/agenda_task_entity.dart';
import '../models/agenda_task.dart';

/// Repository which handles CRUD operations to [AgendaTaskEntity] box.
class AgendaTaskRepository {
  AgendaTaskRepository(Store store) : _box = store.box<AgendaTaskEntity>();

  /// The [Box] handling all database operations of [AgendaTaskEntity].
  late final Box<AgendaTaskEntity> _box;

  /// Returns a stream of [AgendaTaskEntity].
  Stream<List<AgendaTaskEntity>> getTasksStream() {
    return _box
        .query()
        .watch(triggerImmediately: true)
        .map((Query<AgendaTaskEntity> query) => query.find());
  }

  /// Returns all tasks.
  List<AgendaTask> getAllTasks() {
    return _box.getAll().map((AgendaTaskEntity e) => e.toModel).toList();
  }

  /// Returns tasks for a specific date.
  List<AgendaTask> getTasksForDate(DateTime date, List<AgendaTask> tasks) {
    return tasks.where((AgendaTask task) {
      final RecurrenceStrategy strategy = RecurrenceFactory.fromRule(
        task.recurrenceRule,
      );
      return strategy.occursOn(task.baseDate, date);
    }).toList();
  }

  /// Saves a task entity.
  int saveTask(AgendaTaskEntity entity) {
    return _box.put(entity);
  }

  /// Removes a task by id.
  bool removeTask(int id) {
    return _box.remove(id);
  }

  /// Gets a task by id.
  AgendaTask? getTask(int id) {
    return _box.get(id)?.toModel;
  }
}
