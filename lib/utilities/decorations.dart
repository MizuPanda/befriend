import 'package:flutter/material.dart';

class Decorations {
  static InputDecoration loginInputDecoration(
      {required String labelText,
      required bool isWidgetFocused,
      required bool isError,
      required bool lightMode,
      Widget? suffixIcon}) {
    return InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(
              color: lightMode ? Colors.black : Colors.white, width: 1.5),
        ),
        suffixIcon: suffixIcon);
  }

  static BoxDecoration bubbleDecoration(bool lightMode) {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: lightMode ? Colors.black : Colors.white70,
          spreadRadius: 0.8,
          offset: const Offset(0, 2),
          blurRadius: 3,
        ),
      ],
      shape: BoxShape.circle,
    );
  }
}
