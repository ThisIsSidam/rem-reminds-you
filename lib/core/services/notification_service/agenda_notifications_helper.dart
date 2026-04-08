import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../feature/agenda/data/models/agenda_task.dart';
import '../../../feature/agenda/data/repository/agenda_task_repository.dart';
import '../../../feature/settings/presentation/providers/settings_provider.dart';
import '../../../objectbox.g.dart';
import '../../../shared/utils/logger/app_logger.dart';
import '../../../shared/utils/misc_methods.dart';
import '../../extensions/datetime_ext.dart';
import '../../extensions/list_ext.dart';
import 'agenda_task_payload.dart';
import 'notification_service.dart';

class AgendaNotificationsHelper {
  AgendaNotificationsHelper({required Store store})
    : _repo = AgendaTaskRepository(store);

  final AgendaTaskRepository _repo;

  Future<AgendaTaskPayload?> getNextTask() async {
    _log('Fetching next agenda task');
    final today = DateTime.now().date;
    final List<AgendaTask> allTasks = _repo.getAllTasks();
    final tasks = _repo.getTasksForDate(today, allTasks);

    // No tasks found
    if (tasks.isEmpty) {
      _log('No tasks found!');
      return null;
    }

    // Get first task which isn't completed
    final nextTask = tasks.firstWhereOrNull((task) => !task.isCompleted(today));

    // No Un-completed task
    if (nextTask == null) {
      _log('No Un-Completed task found!');
      return null;
    }

    return AgendaTaskPayload(
      taskId: nextTask.id,
      taskTitle: nextTask.title,
      isLastTask: tasks.last.id == nextTask.id,
    );
  }

  Future<AgendaTaskPayload?> nextPressed(int agendaTaskId) async {
    _log("Handling 'Next' Pressed on notification");
    final DateTime today = DateTime.now().date;
    _repo.setCompletion(agendaTaskId, today, true);

    return getNextTask();
  }

  Future<void> skipPressed() async {
    // To be implemented
  }

  static Future<void> scheduleNextAgendaNotification() async {
    _log('Scheduling next agenda notification');
    final prefs = await SharedPreferences.getInstance();
    final UserSettingsNotifier notififer = UserSettingsNotifier(prefs: prefs);
    final TimeOfDay agendaTime = notififer.defaultAgendaTime;

    final agendaDateTime = MiscMethods.getAgendaDateTime(agendaTime);
    await NotificationService.scheduleAgenda(agendaDateTime);
    _log('Schedule next agenda notification');
  }

  static void _log(String msg) =>
      AppLogger.i('[AgendaNotificationsHelper] $msg');
}
