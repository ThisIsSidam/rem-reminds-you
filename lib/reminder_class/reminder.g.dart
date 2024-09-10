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
      id: fields[1] as int?,
      dateAndTime: fields[2] as DateTime,
    )
      ..notifRepeatInterval = fields[4] as Duration
      ..mixinRecurringInterval = fields[5] as int
      ..mixinReminderStatus = fields[3] as int;
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.notifRepeatInterval)
      ..writeByte(5)
      ..write(obj.mixinRecurringInterval)
      ..writeByte(3)
      ..write(obj.mixinReminderStatus)
      ..writeByte(2)
      ..write(obj.dateAndTime);
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
