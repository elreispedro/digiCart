import 'package:flutter/material.dart';
import '../utils/text_format_style.dart';

Widget buildHotkeyDisplay(String hotkey, String fileName, Color fontColor) {
  if (hotkey == '') {
    return const SizedBox.shrink();
  }

  return Tooltip(
    message: 'Tecla da atalho: $hotkey',
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.keyboard, size: 14, color: fontColor),
        const SizedBox(width: 5),
        Text(
          hotkey,
          style: textStyleCustom(
            fontSize: 14,
            color: fontColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
