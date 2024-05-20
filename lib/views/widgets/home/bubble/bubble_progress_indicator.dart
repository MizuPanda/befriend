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

  static const List<Color> _spectrumColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  Color _interpolateColor(Color startColor, Color endColor, double factor) {
    return Color.lerp(startColor, endColor, factor) ?? startColor;
  }

  List<Color> _generateGradientColors(int level, double progress) {
    int totalColors = _spectrumColors.length;
    int phase = level % totalColors;
    double factor = (level % 100) / 100;

    Color startColor = _interpolateColor(
      _spectrumColors[phase],
      _spectrumColors[(phase + 1) % totalColors],
      factor,
    );

    // Adjust the brightness based on progress
    Color endColor = _adjustBrightness(startColor, progress);

    return [startColor, endColor];
  }

  Color _adjustBrightness(Color color, double factor) {
    HSVColor hsvColor = HSVColor.fromColor(color);
    HSVColor adjustedColor =
        hsvColor.withValue(hsvColor.value * (0.5 + factor * 0.5));
    return adjustedColor.toColor();
  }

  @override
  Widget build(BuildContext context) {
    // Generate gradient colors based on the level
    List<Color> gradientColors =
        _generateGradientColors(friendship.level, friendship.progress);

    final Gradient gradient = LinearGradient(
      colors: gradientColors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Positioned.fill(
      child: CustomPaint(
        painter: GradientPainter(
          gradient: gradient,
          progress: friendship.progress,
          strokeWidth: BubbleProgressIndicator.strokeWidth,
        ),
      ),
    );
  }
}
