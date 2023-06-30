import 'package:flutter/material.dart';

import 'hide_icon.dart';

class PasswordStackWidget extends StatelessWidget {
  final Widget passwordFieldWidget;
  final bool passwordVisible;
  final Function hidePassword;
  final double? size;

  const PasswordStackWidget(
      {super.key,
      required this.passwordFieldWidget,
      required this.passwordVisible,
      required this.hidePassword,
      this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        passwordFieldWidget,
        HideIconWidget(
          passwordVisible: passwordVisible,
          hidePassword: hidePassword,
          size: size ?? 25,
        )
      ],
    );
  }
}
