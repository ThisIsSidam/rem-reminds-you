import '../../data/models/reminder_base.dart';
import '../../presentation/screens/reminder_screen.dart';

/// For information regarding a reminder being dragged.
class DraggedReminder {
  const DraggedReminder({required this.reminder, required this.section});

  /// Reminder of the tile being dragged.
  final ReminderBase reminder;

  /// Section where the reminder belongs to.
  final ReminderSection section;
}
