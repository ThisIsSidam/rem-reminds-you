// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_interval.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurringIntervalAdapter extends TypeAdapter<RecurringInterval> {
  @override
  final int typeId = 2;

  @override
  RecurringInterval read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurringInterval.none;
      case 1:
        return RecurringInterval.daily;
      case 2:
        return RecurringInterval.weekly;
      case 3:
        return RecurringInterval.weekdays;
      case 4:
        return RecurringInterval.weekends;
      case 5:
        return RecurringInterval.monthly;
      default:
        return RecurringInterval.none;
    }
  }

  @override
  void write(BinaryWriter writer, RecurringInterval obj) {
    switch (obj) {
      case RecurringInterval.none:
        writer.writeByte(0);
      case RecurringInterval.daily:
        writer.writeByte(1);
      case RecurringInterval.weekly:
        writer.writeByte(2);
      case RecurringInterval.weekdays:
        writer.writeByte(3);
      case RecurringInterval.weekends:
        writer.writeByte(4);
      case RecurringInterval.monthly:
        writer.writeByte(5);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringIntervalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
