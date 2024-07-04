import 'package:flutter/material.dart';

class Themes {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.white,
  );

  static final ThemeData lightTheme =
      ThemeData(brightness: Brightness.light, primaryColor: Colors.black);
}
