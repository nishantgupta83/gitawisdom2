// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_quote.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyQuoteAdapter extends TypeAdapter<DailyQuote> {
  @override
  final int typeId = 11;

  @override
  DailyQuote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyQuote(
      id: fields[0] as String,
      description: fields[1] as String,
      reference: fields[2] as String?,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DailyQuote obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.reference)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyQuoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
