class AgendaTaskPayload {
  const AgendaTaskPayload({
    required this.taskId,
    required this.taskTitle,
    required this.isLastTask,
  });

  factory AgendaTaskPayload.fromPayload(Map<String, String?> payload) {
    return AgendaTaskPayload(
      taskId: int.tryParse(payload['taskId'] ?? '0') ?? 0,
      taskTitle: payload['taskTitle'] ?? '',
      isLastTask: payload['isLastTask'] == 'true',
    );
  }

  final String taskTitle;
  final int taskId;
  final bool isLastTask;

  Map<String, String> get payload => {
    'taskId': taskId.toString(),
    'taskTitle': taskTitle,
    'isLastTask': isLastTask.toString(),
  };

  bool get hasTask => taskId > 0 && taskTitle.isNotEmpty;
}
