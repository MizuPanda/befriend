import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Align(
      alignment: Alignment.topRight,
      child: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.settings_outlined,
            size: 35,
            color: Colors.black,
          )),
    ));
  }
}
