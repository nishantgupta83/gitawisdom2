// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookmarkAdapter extends TypeAdapter<Bookmark> {
  @override
  final int typeId = 9;

  @override
  Bookmark read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bookmark(
      id: fields[0] as String,
      userDeviceId: fields[1] as String,
      bookmarkType: fields[2] as BookmarkType,
      referenceId: fields[3] as int,
      chapterId: fields[4] as int,
      title: fields[5] as String,
      contentPreview: fields[6] as String?,
      notes: fields[7] as String?,
      tags: (fields[8] as List).cast<String>(),
      isHighlighted: fields[9] as bool,
      highlightColor: fields[10] as HighlightColor,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
      syncStatus: fields[13] as SyncStatus,
    );
  }

  @override
  void write(BinaryWriter writer, Bookmark obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userDeviceId)
      ..writeByte(2)
      ..write(obj.bookmarkType)
      ..writeByte(3)
      ..write(obj.referenceId)
      ..writeByte(4)
      ..write(obj.chapterId)
      ..writeByte(5)
      ..write(obj.title)
      ..writeByte(6)
      ..write(obj.contentPreview)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.tags)
      ..writeByte(9)
      ..write(obj.isHighlighted)
      ..writeByte(10)
      ..write(obj.highlightColor)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.syncStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
