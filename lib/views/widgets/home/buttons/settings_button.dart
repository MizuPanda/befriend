import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/home_provider.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return SafeArea(
        child: Align(
      alignment: Alignment.topRight,
      child: Consumer<HomeProvider>(builder:
          (BuildContext context, HomeProvider provider, Widget? child) {
        return IconButton(
            onPressed: () {
              provider.goToSettings(context);
            },
            icon: Icon(
              Icons.settings_outlined,
              size: 0.078 * width,
            ));
      }),
    ));
  }
}
