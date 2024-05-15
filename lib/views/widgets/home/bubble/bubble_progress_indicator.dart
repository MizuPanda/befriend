import 'package:befriend/models/objects/friendship.dart';
import 'package:flutter/material.dart';

import '../../../../utilities/gradient_painter.dart';

class BubbleProgressIndicator extends StatelessWidget {
  const BubbleProgressIndicator({
    super.key,
    required this.friendship,
  });

  final Friendship friendship;

  static const double strokeWidth = 16 / 3;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CircularProgressIndicator(
        value: friendship.progress,
        strokeWidth: strokeWidth,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
      ),
    );
  }
}

class BubbleGradientIndicator extends StatelessWidget {
  const BubbleGradientIndicator({
    super.key,
    required this.friendship,
  });

  final Friendship friendship;

  final Gradient _gradient = const LinearGradient(
    colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: GradientPainter(
          gradient: _gradient,
          progress: friendship.progress,
          strokeWidth: BubbleProgressIndicator.strokeWidth,
        ),
      ),
    );
  }
}
