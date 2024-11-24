// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'no_rush_reminders.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoRushRemindersModalAdapter extends TypeAdapter<NoRushRemindersModal> {
  @override
  final int typeId = 3;

  @override
  NoRushRemindersModal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoRushRemindersModal(
      id: fields[0] as int,
      title: fields[1] as String,
      autoSnoozeInterval: fields[4] as Duration?,
    )
      ..dateTime = fields[2] as DateTime
      ..PreParsedTitle = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, NoRushRemindersModal obj) {
    writer
      ..writeByte(5)
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
      other is NoRushRemindersModalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
