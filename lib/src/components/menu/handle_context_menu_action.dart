import 'dart:io';
import 'package:digicart/src/components/snackbar_helper.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/settings_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import 'dialogs/audio_gain_dialog.dart';
import '../../components/menu/font_color_menu.dart';
import 'dialogs/shortcut_dialog.dart';
import 'background_color_menu.dart';

void handleContextMenuAction({
  required BuildContext context,
  required String? value,
  required int index,
  required TapDownDetails details,
  required List<Color?> backgroundColorMedias,
  required List<Color?> fontColorMedias,
  required List<double> volumeMedias,
  required List<String?> hotkeysMedias,
  required List<String?> fileNamesMedias,
  required List<String?> filePathsMedias,
  required List<bool?> isCopying,
  required List<Color> predefinedColors,
  required Color secondaryColor,
  required Color fontColorDefault,
  required Function(void Function()) setState,
  required dynamic player,
  required String mediaVideo,
  required int? selectedIndex,
  required String folderStorageMedia,
}) async {
  if (value == 'remove') {
    setState(() {
      backgroundColorMedias[index] = secondaryColor;
      fontColorMedias[index] = fontColorDefault;
      volumeMedias[index] = kGainDefault;
      hotkeysMedias[index] = kHotkeyDefault;
      if (mediaVideo == filePathsMedias[index]) {
        player.stop();
        mediaVideo = '';
        selectedIndex = null;
      }

      fileNamesMedias[index] = null;
      filePathsMedias[index] = null;
    });
  } else if (value == 'select') {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: kAllowedAudiosExtensions,
      allowMultiple: false,
    );

    if (result != null) {
      final file = result.files.single;
      final ext = path.extension(file.name).toLowerCase().replaceAll('.', '');

      if (!kAllowedAudiosExtensions.contains(ext)) {
        showCustomSnackBar(
          context,
          message:
              'Arquivo "${file.name}" não permitido. Tipos permitidos: ${kAllowedAudiosExtensions.join(', ')}',
          background: Colors.red,
          textColor: second,
          icon: Icons.error,
          iconColor: Colors.red,
        );

        return;
      }

      try {
        folderStorageMedia = SettingsService.mediaSavePath ?? kFolderMedia;
        if (!Directory(folderStorageMedia).existsSync()) {
          folderStorageMedia = kFolderMedia;
        }

        final destinationPath = path.join(folderStorageMedia, file.name);

        setState(() {
          isCopying[index] = true;
        });

        await File(file.path!).copy(destinationPath);
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          fileNamesMedias[index] = file.name;
          filePathsMedias[index] = destinationPath;
          mediaVideo = destinationPath;

          hotkeysMedias[index] = kHotkeyDefault;
          volumeMedias[index] = kGainDefault;
          backgroundColorMedias[index] = defaultColor;
          fontColorMedias[index] = fontColorDefault;
          isCopying[index] = false;
          debugPrint("📀 File copied to: $destinationPath");
        });

        showCustomSnackBar(
          context,
          message: 'Arquivo "${file.name}" copiado com sucesso!',
          background: first,
          textColor: second,
          icon: Icons.check_circle,
          iconColor: Colors.green,
        );
      } catch (e) {
        print(e);
        showCustomSnackBar(
          context,
          message: 'Erro ao copiar o arquivo "${file.name}". erro: $e',
          background: Colors.red,
          textColor: Colors.white,
          icon: Icons.error,
          iconColor: Colors.red,
        );
      }
    }
  } else if (value == 'choose_color') {
    showBackgroundColorMenu(
      context: context,
      details: details,
      index: index,
      predefinedColors: predefinedColors,
      onSelected: (color, i) {
        setState(() => backgroundColorMedias[i] = color);
      },
    );
  } else if (value == 'choose_color_font') {
    showFontColorMenu(
      context: context,
      details: details,
      index: index,
      predefinedColors: predefinedColors,
      onColorSelected: (selectedColor, i) {
        setState(() => fontColorMedias[i] = selectedColor);
      },
    );
  } else if (value == 'select_audio_gain') {
    showAudioGainDialog(
      context: context,
      index: index,
      volumeMedias: volumeMedias,
      fontColorDefault: fontColorDefault,
      onSaved: (nivel, i) {
        setState(() => volumeMedias[i] = nivel);
      },
    );
  } else if (value == 'set_shortcut') {
    showShortcutDialog(
      context: context,
      index: index,
      hotkeysMedias: hotkeysMedias,
      onSaved: (shortcut, i) {
        setState(() => hotkeysMedias[i] = shortcut);
      },
    );
  }
}
