import 'dart:math';

import 'package:flutter/cupertino.dart';

class Randomizer {
  static LinearGradient linearGradient() {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_randColor(), _randColor()],
    );
  }

  static Color _randColor() {
    Random r = Random();
    int max = 255;
    return Color.fromRGBO(r.nextInt(max), r.nextInt(max), r.nextInt(max), 1);
  }
}