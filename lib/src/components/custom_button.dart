import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_format_style.dart';

class CustomActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color hoverColor;
  final Color pressedColor;

  const CustomActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = first,
    this.textColor = second,
    this.hoverColor = colorHover,
    this.pressedColor = first,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return pressedColor;
          if (states.contains(WidgetState.hovered)) return hoverColor;
          return backgroundColor;
        }),
        foregroundColor: WidgetStatePropertyAll(textColor),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        overlayColor: WidgetStatePropertyAll(
          Colors.white.withValues(alpha: .1),
        ),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return 6;
          if (states.contains(WidgetState.pressed)) return 2;
          return 4;
        }),
      ),
      child: Text(
        label,
        style: textStyleCustom(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
