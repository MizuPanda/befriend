import 'package:befriend/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utilities/decorations.dart';
import 'base_form_field.dart';
import 'hide_icon.dart';

class PasswordFormField extends StatelessWidget {
  const PasswordFormField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
        builder: (BuildContext context, LoginProvider provider, Widget? child) {
      return BaseTextField(
          focusNode: provider.passwordFocusNode,
          onSaved: (String? s) {},
          validator: (String? s) {
            return null;
          },
          keyboardType: provider.keyboardType(),
          obscureText: !provider.passwordVisible,
          decoration: Decorations.loginInputDecoration(
            labelText: 'Enter your password',
            isWidgetFocused: provider.isPasswordFocused,
            suffixIcon: HideIconButton(
                hidePassword: provider.hidePassword,
                passwordVisible: provider.passwordVisible),
          ));
    });
  }
}
