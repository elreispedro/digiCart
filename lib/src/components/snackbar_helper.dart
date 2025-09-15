import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_format_style.dart';

void showCustomSnackBar(
  BuildContext context, {
  required String message,
  IconData? icon,
  Color? background,
  Color? textColor,
  Color? iconColor,
  Duration duration = const Duration(milliseconds: 1500),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: background ?? first,
      content: Row(
        children: [
          if (icon != null) Icon(icon, color: iconColor ?? second),
          if (icon != null) const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: textStyleCustom(color: textColor ?? second),
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: duration,
    ),
  );
}
