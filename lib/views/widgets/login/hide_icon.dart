import 'package:flutter/material.dart';

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
    return IconButton(
        onPressed: () {
          hidePassword();
        },
        icon: Icon(
          passwordVisible ? Icons.visibility : Icons.visibility_off,
          color: passwordVisible ? Colors.black : Colors.grey,
        ));
  }
}
