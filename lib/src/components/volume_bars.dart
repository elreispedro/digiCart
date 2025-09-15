import 'package:flutter/material.dart';
import '../utils/text_format_style.dart';

Widget buildVolumeBars(double volume, String fileName, Color fontColor) {
  int numberOfBars = (volume / 20).ceil();

  if (fileName == '') {
    return const SizedBox.shrink();
  }

  return Tooltip(
    message: 'Volume configurado: ${volume.floor()}',
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${volume.floor()}%',
            style: textStyleCustom(
              fontSize: 13,
              color: fontColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 5),
          Row(
            children: List.generate(5, (index) {
              return Container(
                width: 3,
                height: (index < numberOfBars ? (index + 1) * 3 : 3).toDouble(),
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: index < numberOfBars ? fontColor : Colors.grey[50],
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ],
      ),
    ),
  );
}
