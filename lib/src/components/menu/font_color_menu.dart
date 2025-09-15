import 'package:flutter/material.dart';
import '../../utils/colors.dart';

Future<void> showFontColorMenu({
  required BuildContext context,
  required TapDownDetails details,
  required int index,
  required List<Color> predefinedColors,
  required void Function(Color selected, int index) onColorSelected,
}) async {
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;
  final Offset position = details.globalPosition;

  final value = await showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      overlay.size.width - position.dx,
      overlay.size.height - position.dy,
    ),
    color: second,
    items: List.generate((predefinedColors.length / 4).ceil(), (row) {
      return PopupMenuItem<String>(
        enabled: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: predefinedColors
              .skip(row * 4)
              .take(4)
              .map(
                (color) => GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(color.value.toString());
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(color: first, width: 1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );
    }),
  );

  if (value != null) {
    final selectedColor = predefinedColors.firstWhere(
      (color) => color.value.toString() == value,
    );
    onColorSelected(selectedColor, index);
  }
}
