import 'package:befriend/providers/login_provider.dart';
import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:befriend/views/widgets/login/login_password_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/login/login_email_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginProvider _provider = LoginProvider();

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
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: const EdgeInsets.all(20.0),
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
                    children: [
                      const EmailFormField(
                        labelText: 'Enter your email',
                      ),
                      const SizedBox(height: 20.0),
                      const PasswordFormField(),
                      const SizedBox(height: 20.0),
                      Row(
                        children: [
                          OutlinedButton(
                            style: const ButtonStyle(
                                shadowColor:
                                    MaterialStatePropertyAll(Colors.black),
                                side: MaterialStatePropertyAll(
                                    BorderSide(width: 1, color: Colors.blue))),
                            onPressed: () {
                              _provider.navigateToSignUp(context);
                            },
                            child: const Text('Sign up'),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () async {
                              await _provider.login(context);
                            },
                            style: const ButtonStyle(enableFeedback: true),
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _provider.openForgotPasswordPage(context);
                          },
                          child: const Text('Forgot your password?'),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
