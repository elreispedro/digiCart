// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_collection.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaCollectionAdapter extends TypeAdapter<MediaCollection> {
  @override
  final int typeId = 0;

  @override
  MediaCollection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaCollection(
      collectionName: fields[0] as String,
      mediaPaths: (fields[1] as List).cast<String?>(),
      backgroundColor: (fields[2] as List).cast<Color?>(),
      fontColor: (fields[3] as List).cast<Color?>(),
      gains: (fields[4] as List).cast<double?>(),
      hotKeys: (fields[5] as List).cast<String?>(),
    );
  }

  @override
  void write(BinaryWriter writer, MediaCollection obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.collectionName)
      ..writeByte(1)
      ..write(obj.mediaPaths)
      ..writeByte(2)
      ..write(obj.backgroundColor)
      ..writeByte(3)
      ..write(obj.fontColor)
      ..writeByte(4)
      ..write(obj.gains)
      ..writeByte(5)
      ..write(obj.hotKeys);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaCollectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
