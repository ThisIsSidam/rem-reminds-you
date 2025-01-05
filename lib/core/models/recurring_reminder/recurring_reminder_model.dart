import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import '../../enums/recurring_interval.dart';
import '../basic_reminder_model.dart';

part 'recurring_reminder_model.freezed.dart';
part 'recurring_reminder_model.g.dart';

class RecurringIntervalConverter
    extends JsonConverter<RecurringInterval, String> {
  const RecurringIntervalConverter();

  @override
  RecurringInterval fromJson(String json) {
    return RecurringInterval.values.firstWhere(
      (e) => e.toString().split('.').last == json,
      orElse: () => RecurringInterval.daily, // Default fallback
    );
  }

  @override
  String toJson(RecurringInterval object) {
    return object.toString().split('.').last;
  }
}

@freezed
class RecurringReminderModel with _$RecurringReminderModel {
  @HiveType(typeId: 2)
  const factory RecurringReminderModel({
    @HiveField(0) required BasicReminderModel reminder,
    @HiveField(1)
    @RecurringIntervalConverter()
    required RecurringInterval recurringInterval,
    @HiveField(2) required DateTime baseDateTime,
    @HiveField(3) @Default(false) bool paused,
  }) = _RecurringReminderModel;

  const RecurringReminderModel._();

  factory RecurringReminderModel.fromJson(Map<String, String> json) {
    return RecurringReminderModel(
      reminder: BasicReminderModel.fromJson(json),
      recurringInterval:
          RecurringInterval.values[int.parse(json['recurringInterval']!)],
      baseDateTime: DateTime.parse(json['baseDateTime']!),
      paused: json['paused'] == 'true',
    );
  }

  Map<String, String> toJson() {
    final data = reminder.toJson();
    data['recurringInterval'] = recurringInterval.index.toString();
    data['baseDateTime'] = baseDateTime.toIso8601String();
    data['paused'] = paused.toString();
    return data;
  }

  /// Move to the next recurring occurrence.
  RecurringReminderModel moveToNextOccurrence() {
    final increment =
        recurringInterval.getRecurringIncrementDuration(baseDateTime);
    return copyWith(
      baseDateTime:
          increment != null ? baseDateTime.add(increment) : baseDateTime,
      reminder: reminder.copyWith(
          dateTime: baseDateTime.add(increment ?? Duration.zero)),
    );
  }

  /// Move to the previous recurring occurrence.
  RecurringReminderModel moveToPreviousOccurrence() {
    final decrement =
        recurringInterval.getRecurringDecrementDuration(baseDateTime);
    return copyWith(
      baseDateTime:
          decrement != null ? baseDateTime.subtract(decrement) : baseDateTime,
      reminder: reminder.copyWith(
          dateTime: baseDateTime.subtract(decrement ?? Duration.zero)),
    );
  }
}
