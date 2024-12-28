import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/models/authentication/consent_manager.dart';
import 'package:befriend/providers/sign_provider.dart';
import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:befriend/views/widgets/authentication/signup/birthday_picker.dart';
import 'package:befriend/views/widgets/authentication/signup/strength_indicator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../utilities/app_localizations.dart';
import '../widgets/authentication/login/icon_text_field.dart';
import '../widgets/authentication/signup/sign_up.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final SignProvider _provider = SignProvider();

  @override
  void didChangeDependencies() {
    _provider.changedDependencies(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _provider.toDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        appBar: AppBar(
          title: const BefriendTitle(),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
                left: width * 0.036,
                right: width * 0.036,
                top: 0.016 * height,
                bottom: 0.020 * height),
            child: SingleChildScrollView(
              child: Consumer<SignProvider>(builder:
                  (BuildContext context, SignProvider provider, Widget? child) {
                return Form(
                  key: provider.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: AutoSizeText(
                          AppLocalizations.translate(context,
                              key: 'sup_welcome',
                              defaultString:
                                  'Welcome! Begin by creating an account'),
                          style: GoogleFonts.openSans(
                              textStyle: const TextStyle(fontSize: 18)),
                        ),
                      ),
                      SizedBox(height: 0.020 * height),
                      IconTextField(
                        textInputAction: TextInputAction.next,
                        textInputType: TextInputType.emailAddress,
                        iconData: Icons.email,
                        hintText: AppLocalizations.translate(context,
                            key: 'sup_email', defaultString: 'Your email'),
                        onSaved: provider.emailSaved,
                        validator: (String? val) {
                          return provider.emailValidator(val, context);
                        },
                      ),
                      SizedBox(height: 0.020 * height),
                      IconTextField(
                        textInputType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        iconData: Icons.account_circle,
                        hintText: AppLocalizations.translate(context,
                            key: 'sup_username',
                            defaultString: 'Your username'),
                        onSaved: provider.usernameSaved,
                        validator: (String? val) {
                          return provider.usernameValidator(val, context);
                        },
                      ),
                      SizedBox(
                        height: 0.020 * height,
                      ),
                      const BirthdayPicker(),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 0.008 * height, left: 0.033 * width),
                        child: AutoSizeText(
                          AppLocalizations.translate(context,
                              key: 'sup_birthday',
                              defaultString:
                                  'This information will not be displayed on your profile.'),
                          style: GoogleFonts.openSans(
                              fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ),
                      SizedBox(height: 0.015 * height),
                      IconTextField(
                        textInputType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.next,
                        iconData: Icons.lock,
                        hintText: AppLocalizations.translate(context,
                            key: 'sup_password',
                            defaultString: 'Your password'),
                        onChanged: provider.onChanged,
                        onSaved: provider.passwordSaved,
                        validator: (String? val) {
                          return provider.passwordValidator(val, context);
                        },
                        passwordVisible: provider.passwordVisible,
                        hidePassword: provider.hidePassword,
                      ),
                      const PasswordStrengthIndicator(),
                      SizedBox(height: height * 0.020),
                      IconTextField(
                        textInputType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        iconData: Icons.lock,
                        hintText: AppLocalizations.translate(context,
                            key: 'sup_repeat',
                            defaultString: 'Repeat your password'),
                        onSaved: (_) {},
                        validator: (String? val) {
                          return provider.repeatValidator(val, context);
                        },
                        passwordVisible: provider.passwordRepeatVisible,
                        hidePassword: provider.hideRepeat,
                      ),
                      SizedBox(
                        height: 0.020 * height,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: AutoSizeText.rich(TextSpan(
                                style: GoogleFonts.openSans(),
                                children: [
                                  TextSpan(
                                    text:
                                        "${AppLocalizations.translate(context, key: 'sup_checkbox', defaultString: 'By signing up, you consent to the')} ",
                                  ),
                                  TextSpan(
                                      text: AppLocalizations.translate(context,
                                          key: 'sup_privacy',
                                          defaultString: "privacy policy"),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 14),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          await ConsentManager
                                              .showPrivacyPolicyDialog(context);
                                        }),
                                  TextSpan(
                                      text:
                                          " ${AppLocalizations.translate(context, key: 'sup_and', defaultString: 'and to the')} "),
                                  TextSpan(
                                      text: AppLocalizations.translate(context,
                                          key: 'sup_terms',
                                          defaultString:
                                              "terms and conditions"),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 14),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          await ConsentManager
                                              .showTermsConditionsDialog(
                                                  context);
                                        }),
                                  const TextSpan(text: "."),
                                ])),
                          ),
                          const Spacer(),
                          Checkbox(
                              value: provider.hasConsented,
                              onChanged: provider.onCheck),
                        ],
                      ),
                      SizedBox(
                        height: 0.020 * height,
                      ),
                      SignUpButton(
                        onPressed: () async {
                          await provider.signUp(context);
                        },
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
