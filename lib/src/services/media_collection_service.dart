import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:collection/collection.dart';
import '../models/media_collection.dart';

class MediaCollectionService {
  final Box _mediaCollections = Hive.box('mediaCollections');

  List<String> get mediaCollectionNames => _mediaCollections.values
      .cast<MediaCollection>()
      .map((c) => c.collectionName)
      .toList();

  MediaCollection? getMediaCollectionByName(String collectionName) {
    return _mediaCollections.values.cast<MediaCollection>().firstWhereOrNull(
      (mc) => mc.collectionName == collectionName,
    );
  }

  void saveMediaCollection(MediaCollection mediaCollection) {
    _mediaCollections.add(mediaCollection);
    debugPrint(
      'Coleção "${mediaCollection.collectionName}" salva com sucesso.',
    );
  }

  void deleteMediaCollection(String collectionName) {
    final collectionKey = _mediaCollections.keys.firstWhere(
      (key) => _mediaCollections.get(key)?.collectionName == collectionName,
      orElse: () => null,
    );

    if (collectionKey != null) {
      _mediaCollections.delete(collectionKey);
      debugPrint('Coleção "$collectionName" excluída com sucesso.');
    } else {
      debugPrint('Coleção "$collectionName" não encontrada.');
    }
  }

  void updateMediaCollection(
    String collectionName,
    MediaCollection updatedCollection,
  ) {
    final collectionKey = _mediaCollections.keys.firstWhere(
      (key) => _mediaCollections.get(key)?.collectionName == collectionName,
      orElse: () => null,
    );

    if (collectionKey != null) {
      _mediaCollections.put(collectionKey, updatedCollection);
      debugPrint('Coleção "$collectionName" atualizada com sucesso.');
    } else {
      debugPrint('Coleção "$collectionName" não encontrada.');
    }
  }
}
