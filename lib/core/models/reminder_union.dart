import 'package:freezed_annotation/freezed_annotation.dart';

import 'basic_reminder_model.dart';
import 'no_rush_reminder/no_rush_reminders_model.dart';
import 'recurring_reminder/recurring_reminder_model.dart';

part 'reminder_union.freezed.dart';

@freezed
sealed class Reminder with _$Reminder {
  const factory Reminder.basic(BasicReminderModel reminder) = BasicReminder;

  const factory Reminder.recurring(RecurringReminderModel recurringReminder) =
      RecurringReminder;

  const factory Reminder.noRush(NoRushRemindersModel noRushReminder) =
      NoRushReminder;

  const Reminder._();

  /// Factory constructor to parse JSON into the appropriate subtype.
  factory Reminder.fromJson(Map<String, String> json) {
    switch (json['type']) {
      case 'basic':
        return Reminder.basic(BasicReminderModel.fromJson(json));
      case 'recurring':
        return Reminder.recurring(RecurringReminderModel.fromJson(json));
      case 'noRush':
        return Reminder.noRush(NoRushRemindersModel.fromJson(json));
      default:
        throw ArgumentError('Unknown Reminder type: ${json['type']}');
    }
  }

  /// Centralized toJson method to serialize Reminder object
  Map<String, String> toJson() {
    return when(
      basic: (r) => r.toJson()..['type'] = 'basic',
      recurring: (r) => r.toJson()..['type'] = 'recurring',
      noRush: (r) => r.toJson()..['type'] = 'noRush',
    );
  }

  // --- Getters ---
  int get id => when(
        basic: (r) => r.id,
        recurring: (r) => r.reminder.id,
        noRush: (r) => r.id,
      );

  String get title => when(
        basic: (r) => r.title,
        recurring: (r) => r.reminder.title,
        noRush: (r) => r.title,
      );

  DateTime get dateTime => when(
        basic: (r) => r.dateTime,
        recurring: (r) => r.reminder.dateTime,
        noRush: (r) => r.dateTime,
      );

  String get preParsedTitle => when(
        basic: (r) => r.preParsedTitle,
        recurring: (r) => r.reminder.preParsedTitle,
        noRush: (r) => '',
      );

  Duration? get autoSnoozeInterval => when(
        basic: (r) => r.autoSnoozeInterval,
        recurring: (r) => r.reminder.autoSnoozeInterval,
        noRush: (r) => r.autoSnoozeInterval,
      );

  /// Compare if the current reminder's time is before another's time.
  bool compareTo(Reminder other) {
    return dateTime.isBefore(other.dateTime);
  }

  /// Get the duration difference between the reminder time and now.
  Duration timeDifference() {
    return dateTime.difference(DateTime.now());
  }

  /// Check if the current time is within 5 seconds before the reminder time.
  bool isTimesUp() {
    return dateTime.isBefore(DateTime.now().add(const Duration(seconds: 5)));
  }

// --- COPYWITH ---
// Reminder copyWith({
//   int? id,
//   String? title,
//   DateTime? dateTime,
//   String? preParsedTitle,
//   Duration? autoSnoozeInterval,
//   RecurringInterval? recurringInterval,
//   DateTime? baseDateTime,
//   bool? paused,
// }) {
//   return map(
//     basic: (r) => Reminder.basic(r.reminder.copyWith(
//       id: id ?? r.reminder.id,
//       title: title ?? r.reminder.title,
//       dateTime: dateTime ?? r.reminder.dateTime,
//       preParsedTitle: preParsedTitle ?? r.reminder.preParsedTitle,
//       autoSnoozeInterval: autoSnoozeInterval ?? r.reminder.autoSnoozeInterval,
//     )),
//     recurring: (r) => Reminder.recurring(r.recurringReminder.copyWith(
//       reminder: r.recurringReminder.reminder.copyWith(
//         id: id ?? r.recurringReminder.reminder.id,
//         title: title ?? r.recurringReminder.reminder.title,
//         dateTime: dateTime ?? r.recurringReminder.reminder.dateTime,
//         preParsedTitle:
//             preParsedTitle ?? r.recurringReminder.reminder.preParsedTitle,
//         autoSnoozeInterval: autoSnoozeInterval ??
//             r.recurringReminder.reminder.autoSnoozeInterval,
//       ),
//       recurringInterval:
//           recurringInterval ?? r.recurringReminder.recurringInterval,
//       baseDateTime: baseDateTime ?? r.recurringReminder.baseDateTime,
//       paused: paused ?? r.recurringReminder.paused,
//     )),
//     noRush: (r) => Reminder.noRush(r.noRushReminder.copyWith(
//       id: id ?? r.noRushReminder.id,
//       title: title ?? r.noRushReminder.title,
//       dateTime: dateTime ?? r.noRushReminder.dateTime,
//       autoSnoozeInterval:
//           autoSnoozeInterval ?? r.noRushReminder.autoSnoozeInterval,
//     )),
//   );
// }
}
