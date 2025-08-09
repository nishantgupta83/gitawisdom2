// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scenario.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScenarioAdapter extends TypeAdapter<Scenario> {
  @override
  final int typeId = 5;

  @override
  Scenario read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Scenario(
      title: fields[0] as String,
      description: fields[1] as String,
      category: fields[2] as String,
      chapter: fields[3] as int,
      heartResponse: fields[4] as String,
      dutyResponse: fields[5] as String,
      gitaWisdom: fields[6] as String,
      verse: fields[7] as String?,
      verseNumber: fields[8] as String?,
      tags: (fields[9] as List?)?.cast<String>(),
      actionSteps: (fields[10] as List?)?.cast<String>(),
      createdAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Scenario obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.chapter)
      ..writeByte(4)
      ..write(obj.heartResponse)
      ..writeByte(5)
      ..write(obj.dutyResponse)
      ..writeByte(6)
      ..write(obj.gitaWisdom)
      ..writeByte(7)
      ..write(obj.verse)
      ..writeByte(8)
      ..write(obj.verseNumber)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.actionSteps)
      ..writeByte(11)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScenarioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
