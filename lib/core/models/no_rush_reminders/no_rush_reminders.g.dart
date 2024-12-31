// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'no_rush_reminders.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoRushRemindersModelAdapter extends TypeAdapter<NoRushRemindersModel> {
  @override
  final int typeId = 3;

  @override
  NoRushRemindersModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoRushRemindersModel(
      id: fields[0] as int,
      title: fields[1] as String,
      autoSnoozeInterval: fields[4] as Duration?,
      dateTime: fields[2] as DateTime,
      customSound: fields[5] as String?,
    )..PreParsedTitle = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, NoRushRemindersModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.PreParsedTitle)
      ..writeByte(4)
      ..write(obj.autoSnoozeInterval)
      ..writeByte(5)
      ..write(obj.customSound);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoRushRemindersModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
