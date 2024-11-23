import 'package:hive/hive.dart';

import '../reminder_modal/reminder_modal.dart';

part 'no_rush_reminders.g.dart';

@HiveType(typeId: 3)
class NoRushRemindersModal extends ReminderModal {
  NoRushRemindersModal({
    required super.id,
    required super.title,
    required super.dateTime,
    required super.autoSnoozeInterval,
  }) : super(PreParsedTitle: title);

  // Will use fromJson and toJson methods of ReminderModal as the attributes
  // are same
}
