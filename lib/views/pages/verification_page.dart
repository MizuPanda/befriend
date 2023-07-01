import 'package:befriend/providers/verification_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final VerificationProvider _provider = VerificationProvider();
  @override
  void dispose() {
    _provider.toDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: _provider,
        builder: (BuildContext context, Widget? child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Email Verification'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<VerificationProvider>(builder:
                  (BuildContext context, VerificationProvider provider,
                      Widget? child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Enter the verification code sent to your email:',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      key: provider.formKey,
                      validator: provider.validator,
                      controller: provider.codeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Verification Code',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        TextButton(
                            onPressed: () {
                              FirebaseAuth.instance.currentUser!
                                  .sendEmailVerification();
                            },
                            child: const Text('Send again')),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () async {
                            await provider.verifyCode();
                          },
                          child: const Text('Verify'),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          );
        });
  }
}
