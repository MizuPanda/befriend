import 'package:befriend/providers/material_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class PictureCardShimmer extends StatelessWidget {
  const PictureCardShimmer({
    super.key,
  });

  final double _likeSizeWidthMultiplier = 35 / 448;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Consumer<MaterialProvider>(builder: (BuildContext context,
        MaterialProvider materialProvider, Widget? child) {
      final bool isLightMode = materialProvider.isLightMode(context);

      return Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Shimmer.fromColors(
              baseColor: isLightMode ? Colors.grey[300]! : Colors.grey[800]!,
              highlightColor:
                  isLightMode ? Colors.grey[100]! : Colors.grey[600]!,
              child: Container(
                width: width,
                height: width,
                color: isLightMode ? Colors.white : Colors.black,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.0 / 448 * width),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 0.01 * height,
                  ),
                  Row(
                    children: [
                      Shimmer.fromColors(
                        baseColor:
                            isLightMode ? Colors.grey[300]! : Colors.grey[800]!,
                        highlightColor:
                            isLightMode ? Colors.grey[100]! : Colors.grey[600]!,
                        child: Icon(Icons.favorite,
                            color: Colors.white,
                            size: _likeSizeWidthMultiplier * width),
                      ),
                      SizedBox(width: 8 / 448 * width),
                      Shimmer.fromColors(
                        baseColor:
                            isLightMode ? Colors.grey[300]! : Colors.grey[800]!,
                        highlightColor:
                            isLightMode ? Colors.grey[100]! : Colors.grey[600]!,
                        child: Container(
                          width: width *
                              0.5, // Width of the shimmer for the like count
                          height: 0.015 *
                              height, // Height of the shimmer for the like count
                          color: isLightMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 0.010 * height,
                  ),
                  Shimmer.fromColors(
                    baseColor:
                        isLightMode ? Colors.grey[300]! : Colors.grey[800]!,
                    highlightColor:
                        isLightMode ? Colors.grey[100]! : Colors.grey[600]!,
                    child: Container(
                      width: width * 0.7, // Width of the shimmer for the text
                      height:
                          0.020 * height, // Height of the shimmer for the text
                      color: isLightMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 0.008 * height),
                  Shimmer.fromColors(
                    baseColor:
                        isLightMode ? Colors.grey[300]! : Colors.grey[800]!,
                    highlightColor:
                        isLightMode ? Colors.grey[100]! : Colors.grey[600]!,
                    child: Container(
                      width: width * 0.2, // Width of the shimmer for the text
                      height:
                          0.015 * height, // Height of the shimmer for the text
                      color: isLightMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 0.016 * height),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
