import '../../../feature/agenda/data/models/agenda_task.dart';
import '../../../feature/agenda/data/repository/agenda_task_repository.dart';
import '../../../objectbox.g.dart';
import '../../extensions/datetime_ext.dart';
import '../../extensions/list_ext.dart';

typedef NextAgendaTask = ({AgendaTask? task, bool isLast});

class AgendaNotificationsHelper {
  AgendaNotificationsHelper({required Store store})
    : _repo = AgendaTaskRepository(store);

  final AgendaTaskRepository _repo;

  Future<NextAgendaTask> getNextTask() async {
    final today = DateTime.now().date;
    final List<AgendaTask> allTasks = _repo.getAllTasks();
    final tasks = _repo.getTasksForDate(today, allTasks);

    // No tasks found
    if (tasks.isEmpty) return (task: null, isLast: false);

    // Get first task which isn't completed
    final nextTask = tasks.firstWhereOrNull((task) => !task.isCompleted(today));

    // No new task
    if (nextTask == null) return (task: null, isLast: false);

    return (task: nextTask, isLast: tasks.last.id == nextTask.id);
  }

  Future<NextAgendaTask> nextPressed(int agendaTaskId) async {
    final DateTime today = DateTime.now().date;
    _repo.setCompletion(agendaTaskId, today, true);

    return getNextTask();
  }

  Future<void> skipPressed() async {
    // To be implemented
  }
}
