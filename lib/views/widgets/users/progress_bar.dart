import 'package:befriend/providers/material_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProgressBar extends StatelessWidget {
  final double progress; // Current progress (0.0 to 1.0)
  final int numberOfSeparators; // Number of separators to display

  const ProgressBar({
    Key? key,
    required this.progress,
    this.numberOfSeparators = 9, // Default to 9 for 10% increments
  }) : super(key: key);

  static const double _heightMultiplier = 0.02;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (BuildContext context,
        MaterialProvider materialProvider, Widget? child) {
      final bool lightMode = materialProvider.isLightMode(context);
      final double height = MediaQuery.of(context).size.height;

      return LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth; // 80% of the screen width
          return Container(
            width: width,
            height: height * _heightMultiplier,
            decoration: BoxDecoration(
              color: lightMode ? const Color(0xFFE0E0E0) : Colors.blueGrey,
              borderRadius:
                  BorderRadius.circular(height * _heightMultiplier / 2),
              boxShadow: [
                BoxShadow(
                  color: lightMode
                      ? Colors.black.withOpacity(0.2)
                      : Colors.white.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(height * _heightMultiplier / 2),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: width * progress,
                      height: height * _heightMultiplier,
                      color: lightMode
                          ? const Color(0xFF76FF03)
                          : Colors.greenAccent,
                    ),
                  ),
                ),
                ..._buildSeparators(width, height, lightMode),
              ],
            ),
          );
        },
      );
    });
  }

  List<Widget> _buildSeparators(double width, double height, bool lightMode) {
    List<Widget> separators = [];
    double separatorWidth = width / (numberOfSeparators + 1);
    for (int i = 1; i <= numberOfSeparators; i++) {
      separators.add(
        Positioned(
          left: separatorWidth * i,
          child: Container(
            height: height * _heightMultiplier,
            width: 2 / 448 * width, // Width of the separator line
            color: lightMode ? Colors.white : Colors.grey,
          ),
        ),
      );
    }
    return separators;
  }
}
