import 'package:hive/hive.dart';
import 'dart:ui';

part 'media_collection.g.dart';

class ColorAdapter extends TypeAdapter<Color> {
  @override
  final int typeId = 1;

  @override
  Color read(BinaryReader reader) {
    int value = reader.readInt();
    return Color(value);
  }

  @override
  void write(BinaryWriter writer, Color obj) {
    writer.writeInt(obj.value);
  }
}

@HiveType(typeId: 0)
class MediaCollection {
  @HiveField(0)
  final String collectionName;

  @HiveField(1)
  final List<String?> mediaPaths;

  @HiveField(2)
  final List<Color?> backgroundColor;

  @HiveField(3)
  final List<Color?> fontColor;

  @HiveField(4)
  final List<double?> gains;

  @HiveField(5)
  final List<String?> hotKeys;

  MediaCollection({
    required this.collectionName,
    required this.mediaPaths,
    required this.backgroundColor,
    required this.fontColor,
    required this.gains,
    required this.hotKeys,
  });

  factory MediaCollection.fromMap(Map<String, dynamic> map) {
    return MediaCollection(
      collectionName: map['collectionName'] as String,
      mediaPaths: List<String>.from(map['mediaPaths']),
      backgroundColor: List<Color>.from(map['backgroundColor']),
      fontColor: List<Color>.from(map['fontColor']),
      gains: List<double>.from(map['gains']),
      hotKeys: List<String>.from(map['hotKey'])
    );
  }

  @override
  String toString() {
    return '''
MediaCollection(
  collectionName: $collectionName,
  mediaPaths: $mediaPaths,
  backgroundColor: $backgroundColor,
  fontColor: $fontColor,
  gains: $gains,
  hotKeys: $hotKeys
)''';
  }
}
