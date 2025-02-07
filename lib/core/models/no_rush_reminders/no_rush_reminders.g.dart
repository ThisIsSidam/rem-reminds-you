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
      id: (fields[0] as num).toInt(),
      title: fields[1] as String,
      autoSnoozeInterval: fields[4] as Duration?,
      dateTime: fields[2] as DateTime,
    )..preParsedTitle = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, NoRushRemindersModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.dateTime)
      ..writeByte(3)
      ..write(obj.preParsedTitle)
      ..writeByte(4)
      ..write(obj.autoSnoozeInterval);
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
