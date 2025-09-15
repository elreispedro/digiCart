import 'package:flutter/material.dart';

BoxDecoration boxDecorationCustom(Color first, Color second) {
  return BoxDecoration(
    gradient: LinearGradient(colors: <Color>[first, second]),
    borderRadius: BorderRadius.circular(10),
  );
}
