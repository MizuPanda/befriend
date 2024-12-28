import 'package:befriend/providers/login_provider.dart';
import 'package:befriend/providers/material_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/app_localizations.dart';
import '../../../../utilities/decorations.dart';
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
      return Consumer(builder: (BuildContext context,
          MaterialProvider materialProvider, Widget? child) {
        final bool lightMode = materialProvider.isLightMode(context);

        return BaseFormField(
            action: TextInputAction.done,
            focusNode: provider.passwordFocusNode,
            onSaved: provider.passwordSaved,
            validator: (String? val) {
              return provider.passwordValidator(context, val);
            },
            keyboardType: provider.keyboardType(),
            obscureText: !provider.passwordVisible,
            decoration: Decorations.loginInputDecoration(
              lightMode: lightMode,
              labelText: AppLocalizations.translate(context,
                  key: 'lpf_enter', defaultString: 'Enter your password'),
              isWidgetFocused: provider.isPasswordFocused,
              isError: provider.isPassError,
              suffixIcon: HideIconButton(
                  hidePassword: provider.hidePassword,
                  passwordVisible: provider.passwordVisible),
            ));
      });
    });
  }
}
