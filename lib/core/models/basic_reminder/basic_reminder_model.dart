import 'package:Rem/core/constants/const_strings.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'basic_reminder_model.freezed.dart';
part 'basic_reminder_model.g.dart';

@freezed
class BasicReminderModel with _$BasicReminderModel {
  @HiveType(typeId: 1)
  const factory BasicReminderModel({
    @HiveField(0) required int id,
    @HiveField(1) required String title,
    @HiveField(2) required DateTime dateTime,
    @HiveField(3) required String preParsedTitle,
    @HiveField(4) Duration? autoSnoozeInterval,
  }) = _BasicReminderModel;

  const BasicReminderModel._();

  factory BasicReminderModel.fromJson(Map<String, String?> json) {
    return BasicReminderModel(
      id: int.tryParse(json['id']!) ?? newReminderID,
      title: json['title']!,
      dateTime: DateTime.parse(json['dateTime']!),
      preParsedTitle: json['PreParsedTitle']!,
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
      'PreParsedTitle': preParsedTitle,
      'autoSnoozeInterval': autoSnoozeInterval?.inMilliseconds.toString() ?? '',
    };
  }

// BasicReminderModel copyWith(
//   int? id,
//   String? title,
//   DateTime dateTime,
//   String? preParsedTitle,
//   Duration? autoSnoozeInterval,
// ) {
//   return BasicReminderModel(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       dateTime: dateTime ?? this.dateTime,
//       preParsedTitle: preParsedTitle ?? this.preParsedTitle,
//       autoSnoozeInterval: autoSnoozeInterval ?? this.autoSnoozeInterval);
// }
}
