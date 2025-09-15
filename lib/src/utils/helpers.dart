import 'package:digicart/src/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'colors.dart';

WindowOptions windowOptionsApp = const WindowOptions(
  alwaysOnTop: true,
  // size: minSizeApp,
  minimumSize: kMinSizeApp,
  center: true,
  title: "digiCart",
  skipTaskbar: false,
);

IconData getVolumeIcon(double volume) {
  if (volume <= 0) {
    return Icons.volume_off; // Volume desligado
  } else if (volume > 0 && volume <= 20) {
    return Icons.volume_mute; // Volume muito baixo
  } else if (volume > 20 && volume <= 40) {
    return Icons.volume_down_alt; // Volume baixo
  } else if (volume > 40 && volume <= 60) {
    return Icons.volume_down; // Volume médio-baixo
  } else if (volume > 60 && volume <= 80) {
    return Icons.volume_up; // Volume médio-alto
  } else {
    return Icons.volume_up_outlined; // Volume alto/máximo
  }
}

String formatTimeRemaining(Duration duration) {
  final int minutes = duration.inSeconds ~/ 60;
  final int seconds = duration.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String formatAudioDeviceName(AudioDevice device) {
  if (device.name.toLowerCase().contains('openal')) {
    return 'OpenAL (Driver Padrão)';
  } else if (device.name.toLowerCase().contains('wasapi')) {
    return 'Dispositivo WASAPI (${device.name.split('/').last})';
  } else if (device.name.toLowerCase() == 'auto') {
    return 'Auto (Seleção Automática)';
  } else {
    return device.name;
  }
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return '${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$minutes:$seconds';
}

String getFileName(String path) {
  return path.split(RegExp(r'[\\/]+')).last.split('.').first;
}

String formatTimestamp(String timestampStr) {
  try {
    final timestamp = int.tryParse(timestampStr);
    if (timestamp == null) return timestampStr;

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  } catch (_) {
    return timestampStr;
  }
}

String removeFileExtension(String fileName) {
  final lastDot = fileName.lastIndexOf('.');
  if (lastDot == -1) return fileName;
  return fileName.substring(0, lastDot);
}

String getExtensionFile(String fileName) {
  try {
    final parts = fileName.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    } else {
      return '';
    }
  } catch (e) {
    return '';
  }
}

String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

List<String> getAllMediaPaths(List<String?> filePaths) {
  List<String> mediaPaths = [];

  for (int i = 0; i < filePaths.length; i++) {
    if (filePaths[i]?.isNotEmpty ?? false) {
      mediaPaths.add(filePaths[i]!);
    } else {
      mediaPaths.add('');
    }
  }

  return mediaPaths;
}

List<Color> getAllBackgroundColors(List<Color?> containerColors) {
  List<Color> result = [];

  for (Color? color in containerColors) {
    result.add(color ?? defaultColor);
  }

  return result;
}

List<Color> getAllFontColors(List<Color?> fontColors, Color fontColorDefault) {
  List<Color> result = [];

  for (Color? color in fontColors) {
    result.add(color ?? fontColorDefault);
  }
  return result;
}

List<double> getAllGains(List<double?> gains, double gainDefault) {
  List<double> result = [];

  for (int i = 0; i < gains.length; i++) {
    if (gains[i] != null) {
      result.add(gains[i]!);
    } else {
      result.add(gainDefault);
    }
  }

  return result;
}

List<String?> getAllHotkeys(List<String?> hotkey, String hotkeyDefault) {
  List<String?> result = [];

  for (int i = 0; i < hotkey.length; i++) {
    if (hotkey[i] != null) {
      result.add(hotkey[i]!);
    } else {
      result.add(hotkeyDefault);
    }
  }

  return result;
}

List<String> replaceDragHere(List<String?> items) {
  return items.map((item) {
    if (item == null || item == '') {
      return '';
    }
    return item;
  }).toList();
}

int getStringIndex(String hotkey, List<String?> hotkeysMedias) {
  for (int i = 0; i < hotkeysMedias.length; i++) {
    if (hotkeysMedias[i]?.toUpperCase() == hotkey.toUpperCase()) {
      print('i: $i');
      return i;
    }
  }
  return -1;
}
