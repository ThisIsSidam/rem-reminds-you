import '../../../objectbox.g.dart';
import '../../../shared/utils/logger/global_logger.dart';
import '../../data/entities/no_rush_entitiy/no_rush_entity.dart';
import '../../data/entities/reminder_entitiy/reminder_entity.dart';
import '../../data/models/reminder/reminder.dart';
import '../../data/models/reminder_base/reminder_base.dart';

class NotificationActionHandler {
  const NotificationActionHandler({
    required this.reminder,
    required this.store,
    required this.type,
  });

  final ReminderBase reminder;
  final Store store;
  final String type;

  /// Redirects to specific done handler based on the type attribute
  void donePressed() {
    gLogger.i('Notification action | Done Button Pressed');

    if (type == 'NoRushReminderModel') {
      _noRushDonePressed();
      return;
    }
    if (type == 'ReminderModel') {
      _normalDonePressed();
    }
  }

  /// Removed reminder from the box
  void _noRushDonePressed() {
    final Box<NoRushReminderEntity> box = store.box<NoRushReminderEntity>();
    final bool deleted = box.remove(reminder.id);
    gLogger.i('No Rush Reminder deletion status: $deleted');
  }

  /// Retreives remidner from box, gets the model instance,
  /// checks whether the reminder is recurring.
  ///
  /// If yes, moves reminder to next occurrence,
  /// if not, removes the reminder from box.
  void _normalDonePressed() {
    final Box<ReminderEntity> box = store.box<ReminderEntity>();
    final ReminderEntity? entity = box.get(reminder.id);
    if (entity == null) {
      gLogger.i('Reminder not found in database | Done action cancelled');
      return;
    }
    final ReminderModel model = entity.toModel;
    if (model.isRecurring) {
      model.moveToNextOccurrence();

      box.put(model.toEntity);
      gLogger.i('Reminder moved to next occurrence : ${model.dateTime}');
      return;
    }
    final bool deleted = box.remove(reminder.id);
    gLogger.i('Reminder deletion status: $deleted');
  }
}
