import 'package:befriend/providers/material_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SearchHistoryShimmer extends StatelessWidget {
  const SearchHistoryShimmer(
      {super.key, required this.hasTrailing, required this.itemCount});

  final bool hasTrailing;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
        itemCount: itemCount, // Number of shimmer placeholders
        itemBuilder: (context, index) {
          return Consumer<MaterialProvider>(builder: (BuildContext context,
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
                ),
                title: Container(
                  height: 12.0,
                  color: isLightMode ? Colors.grey[300] : Colors.grey[800],
                ),
                trailing: hasTrailing
                    ? Icon(
                        Icons.close_rounded,
                        color:
                            isLightMode ? Colors.grey[300] : Colors.grey[800],
                      )
                    : null,
              ),
            );
          });
        },
      ),
    );
  }
}
