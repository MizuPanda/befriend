import 'package:befriend/providers/material_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProgressBar extends StatelessWidget {
  final double progress; // Current progress (0.0 to 1.0)
  final int numberOfSeparators; // Number of separators to display
  final bool isBestFriend; // Determines if the gradient is used

  const ProgressBar({
    super.key,
    required this.progress,
    this.numberOfSeparators = 9, // Default to 9 for 10% increments
    required this.isBestFriend,
  });

  static const double _heightMultiplier = 0.02;

  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialProvider>(
      builder: (BuildContext context, MaterialProvider materialProvider,
          Widget? child) {
        final bool lightMode = materialProvider.isLightMode(context);
        final double height = MediaQuery.of(context).size.height;

        return LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth;

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
                        decoration: BoxDecoration(
                          gradient: isBestFriend
                              ? const LinearGradient(
                                  colors: [
                                    Color.fromRGBO(235, 209, 151, 1),
                                    Color.fromRGBO(187, 155, 73, 1),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                              : null,
                          color: isBestFriend
                              ? null
                              : (lightMode
                                  ? const Color(0xFF76FF03)
                                  : Colors.greenAccent),
                        ),
                      ),
                    ),
                  ),
                  ..._buildSeparators(width, height, lightMode),
                ],
              ),
            );
          },
        );
      },
    );
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
