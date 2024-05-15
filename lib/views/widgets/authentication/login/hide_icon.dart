import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/material_provider.dart';

class HideIconButton extends StatelessWidget {
  const HideIconButton({
    super.key,
    required this.hidePassword,
    required this.passwordVisible,
  });

  final Function hidePassword;
  final bool passwordVisible;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (BuildContext context,
        MaterialProvider materialProvider, Widget? child) {
      final bool lightMode = materialProvider.isLightMode(context);

      return IconButton(
          onPressed: () {
            hidePassword();
          },
          icon: Icon(
            passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: lightMode
                ? (passwordVisible ? Colors.black : Colors.grey)
                : (passwordVisible
                    ? Colors.white.withOpacity(0.8)
                    : Colors.grey),
          ));
    });
  }
}
