import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress; // Current progress (0.0 to 1.0)
  final double height; // Height of the progress bar
  final Color backgroundColor; // Background color of the progress bar
  final Color progressColor; // Color of the progress bar fill
  final Color separatorColor; // Color of the separators
  final int numberOfSeparators; // Number of separators to display

  const ProgressBar({
    Key? key,
    required this.progress,
    this.height = 20,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.progressColor = const Color(0xFF76FF03),
    this.separatorColor = Colors.white,
    this.numberOfSeparators = 10, // Default to 10 for 10% increments
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth; // 80% of the screen width
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(height / 2),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: width * progress,
                    height: height,
                    color: progressColor,
                  ),
                ),
              ),
              ..._buildSeparators(width),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildSeparators(double width) {
    List<Widget> separators = [];
    double separatorWidth = width / (numberOfSeparators + 1);
    for (int i = 1; i <= numberOfSeparators; i++) {
      separators.add(
        Positioned(
          left: separatorWidth * i,
          child: Container(
            height: height,
            width: 2, // Width of the separator line
            color: separatorColor,
          ),
        ),
      );
    }
    return separators;
  }
}
