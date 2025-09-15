import 'package:hive/hive.dart';

class SettingsService {
  static final Box _box = Hive.box('settings');

  // === Dispositivo de Áudio ===
  static String? get selectedAudioDeviceName =>
      _box.get('selectedAudioDeviceName');

  static void setSelectedAudioDeviceName(String name) =>
      _box.put('selectedAudioDeviceName', name);

  // === Caminho para salvar mídias ===
  static String? get mediaSavePath => _box.get('mediaSavePath');

  static void setMediaSavePath(String path) =>
      _box.put('mediaSavePath', path);
}
