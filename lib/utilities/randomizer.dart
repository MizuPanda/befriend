import 'dart:math';

import 'package:flutter/cupertino.dart';

class Randomizer {
  static final Random _random = Random();

  static LinearGradient linearGradient() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_randColor(), _randColor()],
    );
  }

  static Color _randColor() {
    int max = 255;
    return Color.fromRGBO(
        _random.nextInt(max), _random.nextInt(max), _random.nextInt(max), 1);
  }
}
