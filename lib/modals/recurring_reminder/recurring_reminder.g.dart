// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurringReminderModalAdapter
    extends TypeAdapter<RecurringReminderModal> {
  @override
  final int typeId = 1;

  @override
  RecurringReminderModal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringReminderModal(
      id: fields[0] as int,
      title: fields[1] as String,
      dateTime: fields[2] as DateTime,
      PreParsedTitle: fields[3] as String,
      autoSnoozeInterval: fields[4] as Duration?,
      recurringInterval: fields[10] as RecurringInterval,
      baseDateTime: fields[11] as DateTime,
      paused: fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringReminderModal obj) {
    writer
      ..writeByte(8)
      ..writeByte(10)
      ..write(obj.recurringInterval)
      ..writeByte(11)
      ..write(obj.baseDateTime)
      ..writeByte(12)
      ..write(obj.paused)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.PreParsedTitle)
      ..writeByte(4)
      ..write(obj.autoSnoozeInterval);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringReminderModalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
