// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 1;

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      title: fields[0] as String,
      dateAndTime: fields[1] as DateTime,
      id: fields[2] as int?,
      repetitionCount: fields[4] as int,
      recurringInterval: fields[5] as Duration,
      recurringScheduleSet: fields[7] as bool,
    )
      .._reminderStatus = fields[3] as int
      .._repeatInterval = fields[6] as int;
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.dateAndTime)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj._reminderStatus)
      ..writeByte(4)
      ..write(obj.repetitionCount)
      ..writeByte(5)
      ..write(obj.recurringInterval)
      ..writeByte(6)
      ..write(obj._repeatInterval)
      ..writeByte(7)
      ..write(obj.recurringScheduleSet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
