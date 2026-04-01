import 'dart:convert';

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
    }).toList()..sort((AgendaTask a, AgendaTask b) => a.compareTo(b));
  }

  /// Saves a task entity.
  int saveTask(AgendaTaskEntity entity) {
    return _box.put(entity);
  }

  /// Saves multiple task entities.
  void saveTasks(List<AgendaTaskEntity> entities) {
    _box.putMany(entities);
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

  // ----------------------------
  // ----- BACKUP & RESTORE -------------------
  // ----------------------------

  String getBackup() {
    final List<AgendaTaskEntity> tasks = _box.query().build().find();
    final List<Map<String, dynamic>> jsonData = tasks
        .map((AgendaTaskEntity e) => e.toJson())
        .toList();

    return jsonEncode(<String, Object>{
      'tasks': jsonData,
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0',
    });
  }

  void restoreBackup(String json) {
    final Map<String, dynamic> decoded =
        jsonDecode(json) as Map<String, dynamic>;
    final List<Map<String, dynamic>> tasksData =
        (decoded['tasks'] as List<dynamic>).cast<Map<String, dynamic>>();

    final List<AgendaTaskEntity> tasks = tasksData.map((e) {
      return AgendaTaskEntity.fromJson(e, asNew: true);
    }).toList();

    _box.putMany(tasks);
  }
}
