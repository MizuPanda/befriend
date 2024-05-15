import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../providers/material_provider.dart';

class HostingShimmerScreen extends StatelessWidget {
  const HostingShimmerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Consumer<MaterialProvider>(builder: (BuildContext context,
        MaterialProvider materialProvider, Widget? child) {
      final bool isLightMode = materialProvider.isLightMode(context);

      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding:
                EdgeInsets.only(top: 0.020 * height, bottom: 20 / 448 * width),
            child: Shimmer.fromColors(
              baseColor: isLightMode ? Colors.grey[300]! : Colors.grey[800]!,
              highlightColor:
                  isLightMode ? Colors.grey[100]! : Colors.grey[600]!,
              child: Container(
                width: width * 0.6, // Width of the shimmer for the text
                height: 0.020 * height, // Height of the shimmer for the text
                color: isLightMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Number of shimmer items in the list
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 0.008 * height, horizontal: 16.0 / 448 * width),
                  child: Shimmer.fromColors(
                    baseColor:
                        isLightMode ? Colors.grey[300]! : Colors.grey[800]!,
                    highlightColor:
                        isLightMode ? Colors.grey[100]! : Colors.grey[600]!,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22, // Adjust the size of the shimmer circle
                          backgroundColor:
                              isLightMode ? Colors.white : Colors.black,
                        ),
                        SizedBox(width: 0.010 * height),
                        Expanded(
                          child: Container(
                            height:
                                0.020 * height, // Height of the shimmer line
                            color: isLightMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
