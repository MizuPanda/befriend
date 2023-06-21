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
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;
    const useCenter = false;

    final paint = Paint()
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
