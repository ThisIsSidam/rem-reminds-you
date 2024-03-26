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
      repetitionCount: fields[4] as int,
      repetitionInterval: fields[5] as Duration,
      dateAndTime: fields[1] as DateTime,
    )
      ..id = fields[2] as int?
      ..done = fields[3] as bool;
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.dateAndTime)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.done)
      ..writeByte(4)
      ..write(obj.repetitionCount)
      ..writeByte(5)
      ..write(obj.repetitionInterval);
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
