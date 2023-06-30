import 'package:befriend/providers/sign_provider.dart';
import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:befriend/views/widgets/login/password_stack.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../widgets/login/icon_text_field.dart';
import '../widgets/login/sign_up.dart';

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
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const BefriendTitle(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 20),
                    child: Consumer<SignProvider>(builder:
                        (BuildContext context, SignProvider provider,
                            Widget? child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Welcome! Begin by creating an account',
                              style: GoogleFonts.openSans(
                                  textStyle: const TextStyle(fontSize: 18)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const IconTextField(
                              iconData: Icons.email, hintText: 'Your email'),
                          const SizedBox(height: 20),
                          const IconTextField(
                              iconData: Icons.person, hintText: 'Your name'),
                          const SizedBox(height: 20),
                          const IconTextField(
                              iconData: Icons.account_circle,
                              hintText: 'Your username'),
                          const SizedBox(height: 20),
                          PasswordStackWidget(
                            passwordFieldWidget: IconTextField(
                                iconData: Icons.lock,
                                hintText: 'Your password',
                                passwordVisible: _provider.passwordVisible),
                            passwordVisible: _provider.passwordVisible,
                            hidePassword: _provider.hidePassword,
                          ),
                          const SizedBox(height: 20),
                          PasswordStackWidget(
                            passwordFieldWidget: IconTextField(
                                iconData: Icons.lock,
                                hintText: 'Repeat your password',
                                passwordVisible:
                                    _provider.passwordRepeatVisible),
                            passwordVisible: _provider.passwordRepeatVisible,
                            hidePassword: _provider.hideRepeat,
                          ),
                          const SizedBox(height: 40),
                          SignUpButton(
                            onPressed: () {
                              _provider.signup();
                            },
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
