import 'package:befriend/providers/material_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SearchedShimmer extends StatelessWidget {
  const SearchedShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10, // Number of shimmer placeholders
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Consumer<MaterialProvider>(builder: (BuildContext context,
              MaterialProvider materialProvider, Widget? child) {
            final bool isLightMode = materialProvider.isLightMode(context);

            return Shimmer.fromColors(
              baseColor: isLightMode ? Colors.grey[300]! : Colors.grey[800]!,
              highlightColor:
                  isLightMode ? Colors.grey[100]! : Colors.grey[600]!,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      isLightMode ? Colors.grey[300] : Colors.grey[800],
                  radius: 24,
                ),
                title: Container(
                  height: 14.0,
                  color: isLightMode ? Colors.grey[300] : Colors.grey[800],
                  margin: const EdgeInsets.only(bottom: 4.0),
                ),
                subtitle: Container(
                  height: 12.0,
                  color: isLightMode ? Colors.grey[300] : Colors.grey[800],
                  margin: const EdgeInsets.only(right: 50.0),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
