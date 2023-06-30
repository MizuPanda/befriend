import 'package:flutter/material.dart';

class Decorations {
  static InputDecoration loginInputDecoration(
      {required String labelText, required bool isWidgetFocused}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: isWidgetFocused ? Colors.blue : Colors.black,
      ),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        borderSide: BorderSide(
          color: isWidgetFocused ? Colors.blue : Colors.black,
          width: 2.0,
        ),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        borderSide: BorderSide(color: Colors.black, width: 1.5),
      ),
    );
  }
}
