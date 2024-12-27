import 'package:flutter/material.dart';

import '../../../../models/objects/friendship.dart';
import '../../../../utilities/gradient_painter.dart';

class BubbleProgressIndicator extends StatelessWidget {
  const BubbleProgressIndicator({
    super.key,
    required this.friendship,
  });

  final Friendship friendship;

  static const double strokeWidth = 8;

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

  List<Color> _generateGradientColors(
      int level, double progress, String username) {
    if (friendship.isBestFriend) {
      return [
        const Color.fromRGBO(235, 209, 151, 1),
        const Color.fromRGBO(187, 155, 73, 1)
      ];
    }
    Color startColor = _generateStartColor(level, progress, username);
    Color endColor = _generateEndColor(level, progress, username);

    return [startColor, endColor];
  }

  Color _generateStartColor(int level, double progress, String username) {
    // Ensure level is non-negative and progress is between 0 and 1
    level = level < 0 ? 0 : level;
    progress = progress < 0 ? 0 : (progress > 1 ? 1 : progress);

    // Hash the username to get a consistent integer value
    int hash = username.hashCode;

    // Use the hash value to influence the base color calculations
    int baseRed = (level * 30 + hash) % 256;
    int baseGreen = (level * 50 + hash) % 256;
    int baseBlue = (level * 70 + hash) % 256;

    // Adjust color based on progress
    int red = (baseRed + (255 - baseRed) * progress).toInt();
    int green = (baseGreen + (255 - baseGreen) * progress).toInt();
    int blue = (baseBlue + (255 - baseBlue) * progress).toInt();

    return Color.fromARGB(255, red, green, blue);
  }

  Color _generateEndColor(int level, double progress, String username) {
    // Adjust the level slightly to create a different color
    int adjustedLevel = level + 5;

    // Hash the username to get a consistent integer value
    int hash = username.hashCode;

    // Use the hash value to influence the base color calculations
    int baseRed = (adjustedLevel * 30 + hash) % 256;
    int baseGreen = (adjustedLevel * 50 + hash) % 256;
    int baseBlue = (adjustedLevel * 70 + hash) % 256;

    // Adjust color based on progress
    int red = (baseRed + (255 - baseRed) * progress).toInt();
    int green = (baseGreen + (255 - baseGreen) * progress).toInt();
    int blue = (baseBlue + (255 - baseBlue) * progress).toInt();

    return Color.fromARGB(255, red, green, blue);
  }

  @override
  Widget build(BuildContext context) {
    // Generate gradient colors based on the level
    List<Color> gradientColors = _generateGradientColors(
        friendship.level, friendship.progress, friendship.friend.username);

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
