import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/exceptions/failures/failure.dart';
import '../../../recurrence/data/models/recurrence_rule.dart';
import '../../../reminder/data/models/no_rush_reminder.dart';
import '../../../reminder/data/models/reminder.dart';
import '../../../reminder/data/models/reminder_base.dart';

part 'generated/sheet_reminder_form.freezed.dart';
part 'generated/sheet_reminder_form.g.dart';

enum ReminderType { normal, noRush }

@freezed
sealed class SheetReminderForm with _$SheetReminderForm {
  const factory SheetReminderForm({
    required int id,
    required String title,
    required String preParsedTitle,
    required DateTime dateTime,
    required DateTime baseDateTime,
    required Duration autoSnoozeInterval,
    required RecurrenceRule recurrenceRule,
    required bool noRush,
    required bool isPaused,
    required ReminderType? originalType,
  }) = _SheetReminderForm;

  factory SheetReminderForm.fromJson(Map<String, dynamic> json) =>
      _$SheetReminderFormFromJson(json);

  /// Creates the initial/default form of the reminder form.
  /// [leadDuration] and [defaultAutoSnoozeDuration] should be supplied
  /// from the user settings or custom.
  factory SheetReminderForm.initial({
    required Duration leadDuration,
    required Duration defaultAutoSnoozeDuration,
    bool isNoRush = false,
  }) {
    final now = DateTime.now();
    return SheetReminderForm(
      id: 0,
      title: '',
      preParsedTitle: '',
      dateTime: now.add(leadDuration),
      baseDateTime: now,
      autoSnoozeInterval: defaultAutoSnoozeDuration,
      recurrenceRule: RecurrenceRule(),
      noRush: isNoRush,
      isPaused: false,
      originalType: isNoRush ? .noRush : .normal,
    );
  }

  /// Creates the initial state of form based on an existing
  /// reminder instance.
  factory SheetReminderForm.fromReminder(ReminderBase reminder) {
    return switch (reminder) {
      ReminderModel() => SheetReminderForm(
        id: reminder.id,
        title: reminder.title,
        preParsedTitle: reminder.preParsedTitle,
        dateTime: reminder.dateTime,
        baseDateTime: reminder.isRecurring
            ? reminder.baseDateTime
            : DateTime.now(),
        autoSnoozeInterval: reminder.autoSnoozeInterval,
        recurrenceRule: reminder.recurrenceRule,
        noRush: false,
        isPaused: reminder.paused,
        originalType: ReminderType.normal,
      ),
      NoRushReminderModel() => SheetReminderForm(
        id: reminder.id,
        title: reminder.title,
        preParsedTitle: reminder.title,
        dateTime: reminder.dateTime,
        baseDateTime: reminder.dateTime,
        autoSnoozeInterval: Duration.zero,
        recurrenceRule: RecurrenceRule(),
        noRush: true,
        isPaused: false,
        originalType: ReminderType.noRush,
      ),
      _ => throw UnknownReminderTypeFailure(reminder.runtimeType),
    };
  }
}
