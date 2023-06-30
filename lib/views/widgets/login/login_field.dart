import 'package:befriend/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utilities/decorations.dart';

class LoginFormField extends StatelessWidget {
  const LoginFormField({
    super.key,
    required this.labelText,
  });

  final String labelText;

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
        builder: (BuildContext context, LoginProvider provider, Widget? child) {
      return TextFormField(
        autofocus: false,
        onTapOutside: (_) {
          FocusScope.of(context).unfocus();
        },
        keyboardType: TextInputType.emailAddress,
        focusNode: provider.emailFocusNode,
        decoration: Decorations.loginInputDecoration(
            labelText: labelText, isWidgetFocused: provider.isEmailFocused),
      );
    });
  }
}
