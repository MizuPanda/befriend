import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/providers/login_provider.dart';
import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:befriend/views/widgets/authentication/login/login_password_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
            child: Stack(
              children: [
                const SafeArea(
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: BefriendTitle(
                          fontSize: 50,
                        ))),
                Consumer<LoginProvider>(builder: (BuildContext context,
                    LoginProvider provider, Widget? child) {
                  return Form(
                    key: _provider.formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const EmailFormField(
                          labelText: 'Enter your email',
                        ),
                        SizedBox(height: height * _sizedBoxHeightMultiplier),
                        const PasswordFormField(),
                        SizedBox(height: height * _sizedBoxHeightMultiplier),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _provider.navigateToSignUp(context);
                              },
                              child: const AutoSizeText('Sign up'),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () async {
                                await _provider.login(context);
                              },
                              style: const ButtonStyle(enableFeedback: true),
                              child: Align(
                                alignment: Alignment.center,
                                child: _provider.isLoading
                                    ? const CircularProgressIndicator()
                                    : const AutoSizeText('Login'),
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
                              _provider.openForgotPasswordPage(context);
                            },
                            child: const AutoSizeText('Forgot your password?'),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          onPressed: () async {
                            await _provider.openPrivacyPolicy(context);
                          },
                          child: AutoSizeText(
                            'Privacy Policy',
                            style: GoogleFonts.openSans(),
                          )),
                      TextButton(
                          onPressed: () async {
                            await _provider.openTerms(context);
                          },
                          child: AutoSizeText(
                            'Terms & Conditions',
                            style: GoogleFonts.openSans(),
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
