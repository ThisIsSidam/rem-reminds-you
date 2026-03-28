import 'package:objectbox/objectbox.dart';

import '../../../../core/extensions/datetime_ext.dart';
import '../../../recurrence/data/strategies/recurrence_strategy.dart';
import '../../../recurrence/domain/recurrence_factory.dart';
import '../entities/agenda_task_entity.dart';
import '../models/agenda_task.dart';

/// Repository which handles CRUD operations to [AgendaTaskEntity] box.
class AgendaTaskRepository {
  AgendaTaskRepository(Store store) : _box = store.box<AgendaTaskEntity>();

  /// The [Box] handling all database operations of [AgendaTaskEntity].
  final Box<AgendaTaskEntity> _box;

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

  void setCompletion(int id, DateTime dateTime, bool isCompleted) {
    final task = _box.get(id);
    if (task == null) return;

    final int dateAsInt = dateTime.date.millisecondsSinceEpoch;

    final List<int> completedDates = List<int>.from(task.completedDates);

    final bool exists = completedDates.contains(dateAsInt);

    // Only update if something actually changes
    if (isCompleted && !exists) {
      completedDates.add(dateAsInt);
    } else if (!isCompleted && exists) {
      completedDates.remove(dateAsInt);
    } else {
      return; // no-op → avoid DB write
    }

    final updated = task.copyWith(completedDates: completedDates);
    _box.put(updated);
  }
}
