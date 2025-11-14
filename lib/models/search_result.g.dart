// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SearchResultAdapter extends TypeAdapter<SearchResult> {
  @override
  final int typeId = 12;

  @override
  SearchResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SearchResult(
      id: fields[0] as String,
      searchQuery: fields[1] as String,
      resultType: fields[2] as SearchType,
      title: fields[3] as String,
      content: fields[4] as String,
      snippet: fields[5] as String,
      chapterId: fields[6] as int?,
      verseId: fields[7] as int?,
      scenarioId: fields[8] as int?,
      relevanceScore: fields[9] as double,
      searchDate: fields[10] as DateTime,
      metadata: (fields[11] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, SearchResult obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.searchQuery)
      ..writeByte(2)
      ..write(obj.resultType)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.snippet)
      ..writeByte(6)
      ..write(obj.chapterId)
      ..writeByte(7)
      ..write(obj.verseId)
      ..writeByte(8)
      ..write(obj.scenarioId)
      ..writeByte(9)
      ..write(obj.relevanceScore)
      ..writeByte(10)
      ..write(obj.searchDate)
      ..writeByte(11)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SearchTypeAdapter extends TypeAdapter<SearchType> {
  @override
  final int typeId = 13;

  @override
  SearchType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SearchType.verse;
      case 1:
        return SearchType.chapter;
      case 2:
        return SearchType.scenario;
      case 3:
        return SearchType.query;
      default:
        return SearchType.verse;
    }
  }

  @override
  void write(BinaryWriter writer, SearchType obj) {
    switch (obj) {
      case SearchType.verse:
        writer.writeByte(0);
        break;
      case SearchType.chapter:
        writer.writeByte(1);
        break;
      case SearchType.scenario:
        writer.writeByte(2);
        break;
      case SearchType.query:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
