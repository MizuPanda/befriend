import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/providers/login_provider.dart';
import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:befriend/views/widgets/authentication/login/login_password_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../utilities/app_localizations.dart';
import '../widgets/authentication/login/login_email_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginProvider _provider = LoginProvider();

  final double _sizedBoxHeightMultiplier = 0.02;
  @override
  void initState() {
    _provider.init();
    super.initState();
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

    return PopScope(
      canPop: false,
      child: ChangeNotifierProvider.value(
        value: _provider,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            padding: EdgeInsets.all(width * 0.045),
            child: SafeArea(
              child: Consumer<LoginProvider>(builder: (BuildContext context,
                  LoginProvider provider, Widget? child) {
                return Form(
                  key: provider.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const BefriendTitle(
                        fontSize: 50,
                      ),
                      Column(
                        children: [
                          AutoSizeText(
                            AppLocalizations.translate(context,
                                key: 'befriend_devise',
                                defaultString: "~ Expand your social circle ~"),
                            style: GoogleFonts.openSans(fontSize: 20.5),
                          ),
                          SizedBox(
                            height: height * _sizedBoxHeightMultiplier / 1.8,
                          ),
                          EmailFormField(
                            labelText: AppLocalizations.translate(context,
                                key: 'lp_email',
                                defaultString: 'Enter your email'),
                          ),
                          SizedBox(height: height * _sizedBoxHeightMultiplier),
                          const PasswordFormField(),
                          SizedBox(height: height * _sizedBoxHeightMultiplier),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  provider.navigateToSignUp(context);
                                },
                                child: AutoSizeText(AppLocalizations.translate(
                                    context,
                                    key: 'lp_sign',
                                    defaultString: 'Sign up')),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () async {
                                  await provider.login(context);
                                },
                                style: const ButtonStyle(enableFeedback: true),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: provider.isLoading
                                      ? const CircularProgressIndicator()
                                      : AutoSizeText(AppLocalizations.translate(
                                          context,
                                          key: 'lp_login',
                                          defaultString: 'Login')),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  _sizedBoxHeightMultiplier /
                                  2),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                provider.openForgotPasswordPage(context);
                              },
                              child: AutoSizeText(AppLocalizations.translate(
                                  context,
                                  key: 'fpp_forgot',
                                  defaultString: 'Forgot your password?')),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              onPressed: () async {
                                await provider.openPrivacyPolicy(context);
                              },
                              child: AutoSizeText(
                                textAlign: TextAlign.center,
                                AppLocalizations.translate(context,
                                    key: 'lp_privacy',
                                    defaultString: 'Privacy Policy'),
                                style: GoogleFonts.openSans(),
                              )),
                          Flexible(
                            child: TextButton(
                                onPressed: () async {
                                  await provider.openTerms(context);
                                },
                                child: AutoSizeText(
                                  textAlign: TextAlign.center,
                                  AppLocalizations.translate(context,
                                      key: 'lp_terms',
                                      defaultString: 'Terms & Conditions'),
                                  style: GoogleFonts.openSans(),
                                )),
                          )
                        ],
                      )
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
