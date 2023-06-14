import 'package:flutter/material.dart';
import 'dart:math';

class Bubble {
  final String name;
  final double? progress;
  final double distance;
  final double size;
  late double x;
  late double y;
  final Bubble? main;
  final Color? color;
  final Gradient? gradient;

  Bubble(
      {required this.name,
      this.progress,
      required this.distance,
      required this.size,
      this.main,
      this.color,
      this.gradient}) {
    Random rand = Random(); //Distance = 10
    x = rand.nextDouble() * distance; // x=6
    y = sqrt(pow(distance, 2) - pow(x, 2)); //100 - 36 = 64, y = 8
    if (main != null) {
      x += (main!.size + size / 2) / 2;
      y += (main!.size + size / 2) / 2;
    }
    if (rand.nextBool()) {
      x *= -1;
    }
    if (rand.nextBool()) {
      y *= -1;
    }
  }
}
