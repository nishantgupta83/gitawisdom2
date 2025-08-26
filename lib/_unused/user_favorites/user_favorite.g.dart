// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_favorite.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserFavoriteAdapter extends TypeAdapter<UserFavorite> {
  @override
  final int typeId = 6;

  @override
  UserFavorite read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserFavorite(
      scenarioTitle: fields[0] as String,
      favoritedAt: fields[1] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserFavorite obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.scenarioTitle)
      ..writeByte(1)
      ..write(obj.favoritedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserFavoriteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
