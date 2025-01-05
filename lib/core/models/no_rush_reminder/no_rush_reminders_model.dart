import 'package:Rem/feature/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:random_datetime/random_datetime.dart';
import 'package:random_datetime/random_dt_options.dart';

part 'no_rush_reminders_model.freezed.dart';
part 'no_rush_reminders_model.g.dart';

@freezed
class NoRushRemindersModel with _$NoRushRemindersModel {
  @HiveType(typeId: 3)
  const factory NoRushRemindersModel({
    @HiveField(0) required int id,
    @HiveField(1) required String title,
    @HiveField(2) required Duration? autoSnoozeInterval,
    @HiveField(3) required DateTime dateTime,
  }) = _NoRushRemindersModel;

  const NoRushRemindersModel._();

  factory NoRushRemindersModel.fromJson(Map<String, String> json) {
    return NoRushRemindersModel(
      id: int.parse(json['id']!),
      title: json['title']!,
      dateTime: DateTime.parse(json['dateTime']!),
      autoSnoozeInterval: json['autoSnoozeInterval'] != ''
          ? Duration(milliseconds: int.parse(json['autoSnoozeInterval']!))
          : null,
    );
  }

  Map<String, String> toJson() {
    return {
      'id': id.toString(),
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'autoSnoozeInterval': autoSnoozeInterval?.inMilliseconds.toString() ?? '',
    };
  }

  /// Generate DateTime for this new noRush reminder.
  /// Is used in the provider, when creating the new noRush reminder.
  static DateTime generateRandomFutureTime() {
    final UserSettingsNotifier settings = UserSettingsNotifier();
    final TimeOfDay startTime = settings.quietHoursStartTime;
    final TimeOfDay endTime = settings.quietHoursEndTime;

    final DateTime now = DateTime.now();
    final DateTime startDate = now.add(const Duration(days: 3));
    final DateTime endDate = now.add(const Duration(days: 14));

    final RandomDateTime randomTime = RandomDateTime(
      options: RandomDTOptions.withRange(
        yearRange: TimeRange(start: startDate.year, end: endDate.year),
        monthRange: TimeRange(start: startDate.month, end: endDate.month),
        dayRange: TimeRange(start: startDate.day, end: endDate.day),

        // Start is end and vice versa because the time range is during quiet hours.
        hourRange: TimeRange(start: endTime.hour, end: startTime.hour),
        minuteRange: TimeRange(start: endTime.minute, end: startTime.minute),
        secondRange: TimeRange(start: 0, end: 0),
        millisecondRange: TimeRange(start: 0, end: 0),
        microsecondRange: TimeRange(start: 0, end: 0),
      ),
    );

    return randomTime.random();
  }
}
