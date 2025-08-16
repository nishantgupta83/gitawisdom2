// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supported_language.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupportedLanguageAdapter extends TypeAdapter<SupportedLanguage> {
  @override
  final int typeId = 10;

  @override
  SupportedLanguage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupportedLanguage(
      langCode: fields[0] as String,
      nativeName: fields[1] as String,
      englishName: fields[2] as String,
      flagEmoji: fields[3] as String?,
      isRTL: fields[4] as bool,
      isActive: fields[5] as bool,
      sortOrder: fields[6] as int,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SupportedLanguage obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.langCode)
      ..writeByte(1)
      ..write(obj.nativeName)
      ..writeByte(2)
      ..write(obj.englishName)
      ..writeByte(3)
      ..write(obj.flagEmoji)
      ..writeByte(4)
      ..write(obj.isRTL)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.sortOrder)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportedLanguageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
