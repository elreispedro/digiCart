import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

TextStyle textStyleCustom({
  FontWeight fontWeight = FontWeight.normal,
  FontStyle fontStyle = FontStyle.normal,
  double fontSize = 18,
  Color color = first,
  TextOverflow overflow = TextOverflow.clip,
}) {
  return TextStyle(
    color: color,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    fontSize: fontSize,
    overflow: overflow,
  );
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
