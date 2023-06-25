import 'dart:math';

import 'package:flutter/cupertino.dart';

class GradientPainter extends CustomPainter {
  final Gradient gradient;
  final double progress;
  final double strokeWidth;

  GradientPainter(
      {required this.gradient,
      required this.progress,
      required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    const double startAngle = -pi / 2;
    final double sweepAngle = 2 * pi * progress;
    const bool useCenter = false;

    final Paint paint = Paint()
      ..shader =
          gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      useCenter,
      paint,
    );
  }

  @override
  bool shouldRepaint(GradientPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
