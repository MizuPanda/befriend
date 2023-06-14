import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/bubble.dart';

class BubbleWidget extends StatelessWidget {
  final Bubble bubble;
  final Color? color;
  final double _strokeWidth = 4.33;
  final double _textHeight = 25;
  const BubbleWidget({Key? key, required this.bubble, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Builder(builder: (context) {
        if (bubble.progress != null) {
          return SizedBox(
            height: bubble.size + _textHeight,
            child: Column(
              children: [
                Stack(children: [
                  Container(
                    width: bubble.size,
                    height: bubble.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bubble.color ?? color,
                    ),
                  ),
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: bubble.progress,
                      strokeWidth: _strokeWidth,
                      valueColor: bubble.gradient != null
                          ? const AlwaysStoppedAnimation<Color>(
                              Colors.transparent)
                          : null,
                      backgroundColor:
                          bubble.gradient != null ? null : bubble.color,
                      color: bubble.gradient != null ? null : Colors.white,
                    ),
                  ),
                  if (bubble.gradient != null)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GradientPainter(
                          gradient: bubble.gradient!,
                          progress: bubble.progress!,
                          strokeWidth: _strokeWidth,
                        ),
                      ),
                    ),
                ]),
                SizedBox(
                  height: _textHeight,
                  child: Text(
                    bubble.name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'ComingSoon',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return SizedBox(
            height: bubble.size + _textHeight,
            child: Column(
              children: [
                Container(
                  width: bubble.size,
                  height: bubble.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bubble.color ?? color,
                  ),
                ),
                SizedBox(
                  height: _textHeight,
                  child: Text(
                    bubble.name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'ComingSoon',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      }),
    );
  }
}

class _GradientPainter extends CustomPainter {
  final Gradient gradient;
  final double progress;
  final double strokeWidth;

  _GradientPainter(
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
  bool shouldRepaint(_GradientPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
