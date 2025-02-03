import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/home_provider.dart';

class WideSearchButton extends StatelessWidget {
  const WideSearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
        child: Align(
      alignment: Alignment.topLeft,
      child: Consumer<HomeProvider>(builder:
          (BuildContext context, HomeProvider provider, Widget? child) {
        return IconButton(
            onPressed: () {
              provider.pushToWideSearch(context);
            },
            icon: Icon(
              Icons.search_rounded,
              size: 0.078 * width,
            ));
      }),
    ));
  }
}
