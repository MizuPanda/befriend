import 'package:befriend/providers/material_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class MutualShimmer extends StatelessWidget {
  const MutualShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MaterialProvider>(builder: (BuildContext context,
        MaterialProvider materialProvider, Widget? child) {
      final bool isLightMode = materialProvider.isLightMode(context);

      final double height = MediaQuery.of(context).size.height;

      return SizedBox(
        height: height,
        child: ListView.builder(
          itemCount: 12, // Number of shimmer placeholders
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(bottom: 0.008 * height),
            child: Shimmer.fromColors(
              baseColor: isLightMode ? Colors.grey[300]! : Colors.grey[800]!,
              highlightColor:
                  isLightMode ? Colors.grey[100]! : Colors.grey[600]!,
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                ),
                title: Container(
                  height: 16,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
