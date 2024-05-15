import 'package:befriend/providers/material_provider.dart';
import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    // Screen height without the safe area
    final double safeAreaHeight = height -
        (MediaQuery.of(context).padding.top +
            MediaQuery.of(context).padding.bottom);
    final double size = 100 / 973 * height;

    final double positionLeft = (width - size) / 2;
    final double positionTop = (safeAreaHeight - size) / 2;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const Align(alignment: Alignment.topCenter, child: BefriendTitle()),
            ShimmerBubble(
                positionLeft: positionLeft,
                positionTop: positionTop,
                size: size),
            ShimmerBubble(
                positionLeft: positionLeft + size - 18 / 448 * width,
                positionTop: positionTop + size + 136 / 973 * height,
                size: size - 21),
            ShimmerBubble(
                positionLeft: positionLeft - size - 62 / 448 * width,
                positionTop: positionTop + size + 6 / 973 * height,
                size: size + 39),
            ShimmerBubble(
                positionLeft: positionLeft - size - 100 / 448 * width,
                positionTop: positionTop - size - 69 / 973 * height,
                size: size - 10),
            ShimmerBubble(
                positionLeft: positionLeft + size / 2 + 37 / 448 * width,
                positionTop: positionTop - size - 6 / 973 * height,
                size: size - 40),
            ShimmerBubble(
                positionLeft: positionLeft + size / 2 + 139 / 448 * width,
                positionTop: positionTop - size - 63 / 973 * height,
                size: size - 40),
            ShimmerBubble(
                positionLeft: positionLeft + size + 79 / 448 * width,
                positionTop: positionTop + size - 24 / 973 * height,
                size: size + 18),
            ShimmerBubble(
                positionLeft: positionLeft + 16 / 448 * width,
                positionTop: positionTop - size - 226 / 973 * height,
                size: size - 16),
          ],
        ),
      ),
    );
  }
}

class ShimmerBubble extends StatelessWidget {
  const ShimmerBubble(
      {super.key,
      required this.positionLeft,
      required this.positionTop,
      required this.size});

  final double positionLeft;
  final double positionTop;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialProvider>(builder: (BuildContext context,
        MaterialProvider materialProvider, Widget? child) {
      final bool lightMode = materialProvider.isLightMode(context);

      return Positioned(
        left: positionLeft,
        top: positionTop,
        child: Shimmer.fromColors(
          baseColor: lightMode ? Colors.grey[300]! : Colors.grey[800]!,
          highlightColor: lightMode ? Colors.grey[100]! : Colors.grey[600]!,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[400]!,
            ),
          ),
        ),
      );
    });
  }
}
