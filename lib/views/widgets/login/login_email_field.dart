import 'package:befriend/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utilities/decorations.dart';
import 'base_form_field.dart';

class EmailFormField extends StatelessWidget {
  const EmailFormField({
    super.key,
    required this.labelText,
  });

  final String labelText;

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginProvider>(
        builder: (BuildContext context, LoginProvider provider, Widget? child) {
      return BaseTextField(
        action: TextInputAction.next,
        focusNode: provider.emailFocusNode,
        onSaved: provider.emailSaved,
        validator: provider.emailValidator,
        keyboardType: TextInputType.emailAddress,
        obscureText: false,
        decoration: Decorations.loginInputDecoration(
            labelText: labelText,
            isWidgetFocused: provider.isEmailFocused,
            isError: provider.isEmailError),
      );
    });
  }
}
