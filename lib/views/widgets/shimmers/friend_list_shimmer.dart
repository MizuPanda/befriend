import 'package:befriend/providers/material_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class FriendListShimmer extends StatelessWidget {
  const FriendListShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return SizedBox(
      height: height,
      width: MediaQuery.of(context).size.width,
      child: Consumer<MaterialProvider>(builder: (BuildContext context,
          MaterialProvider materialProvider, Widget? child) {
        final bool isLightMode = materialProvider.isLightMode(context);

        return LayoutBuilder(builder: (context, constraints) {
          final double width = constraints.maxWidth;

          return ListView.builder(
              itemCount: 10,
              itemBuilder: (BuildContext context, _) {
                return Padding(
                  padding: EdgeInsets.all(width * 0.02),
                  child: Shimmer.fromColors(
                    baseColor:
                        isLightMode ? Colors.grey[300]! : Colors.grey[800]!,
                    highlightColor:
                        isLightMode ? Colors.grey[100]! : Colors.grey[600]!,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Shimmer for Profile Photo
                            Container(
                              width: 0.1 * width,
                              height: 0.1 * width,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 0.03 * width),
                            // Shimmer for Username
                            Container(
                              width: 0.3 * width,
                              height: 20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            // Shimmer for Level Text
                            Container(
                              width: 0.15 * width,
                              height: 16,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.015 * height),
                        // Shimmer for Progress Bar
                        Container(
                          width: width,
                          height: height * 0.025,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        });
      }),
    );
  }
}
