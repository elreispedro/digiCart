import 'package:digicart/src/utils/text_format_style.dart';
import 'package:flutter/material.dart';
import '../utils/helpers.dart';

Widget buildFileNameDisplay(String fileName, Color fontColor) {
  if (fileName.isEmpty) {
    return const SizedBox.shrink();
  }

  return Text(
    getFileName(fileName),
    textAlign: TextAlign.center,
    overflow: TextOverflow.ellipsis,
    style: textStyleCustom(fontSize: 12, color: fontColor),
  );
}
