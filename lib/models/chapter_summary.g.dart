// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_summary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChapterSummaryAdapter extends TypeAdapter<ChapterSummary> {
  @override
  final int typeId = 3;

  @override
  ChapterSummary read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChapterSummary(
      chapterId: fields[0] as int,
      title: fields[1] as String,
      subtitle: fields[2] as String?,
      scenarioCount: fields[3] as int,
      verseCount: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ChapterSummary obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.chapterId)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subtitle)
      ..writeByte(3)
      ..write(obj.scenarioCount)
      ..writeByte(4)
      ..write(obj.verseCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterSummaryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
