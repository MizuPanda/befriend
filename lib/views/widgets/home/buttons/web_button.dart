import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/home_provider.dart';

class WebButton extends StatelessWidget {
  const WebButton({super.key});

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
              provider.pushToWeb(context);
            },
            icon: Icon(
              Icons.language_rounded,
              size: 0.078 * width,
            ));
      }),
    ));
  }
}
