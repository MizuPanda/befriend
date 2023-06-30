import 'package:befriend/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utilities/decorations.dart';

class LoginPasswordField extends StatelessWidget {
  const LoginPasswordField({
    super.key,
    required this.labelText,
  });

  final String labelText;

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
        builder: (BuildContext context, LoginProvider provider, Widget? child) {
      return TextFormField(
          focusNode: provider.passwordFocusNode,
          onTapOutside: (_) {
            FocusScope.of(context).unfocus();
          },
          obscureText: !provider.passwordVisible,
          keyboardType: provider.passwordVisible
              ? TextInputType.visiblePassword
              : TextInputType.text,
          decoration: Decorations.loginInputDecoration(
              labelText: labelText,
              isWidgetFocused: provider.isPasswordFocused));
    });
  }
}
