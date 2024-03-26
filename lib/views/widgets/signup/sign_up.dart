import 'package:befriend/providers/sign_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpButton extends StatefulWidget {
  const SignUpButton({
    super.key,
    required this.onPressed,
  });

  final Function() onPressed;

  @override
  State<SignUpButton> createState() => _SignUpButtonState();
}

class _SignUpButtonState extends State<SignUpButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: const ButtonStyle(
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ))),
        onPressed: widget.onPressed,
        child: Consumer<SignProvider>(
          builder:
              (BuildContext context, SignProvider provider, Widget? child) {
            if (provider.loading) {
              return const CircularProgressIndicator(
                color: Colors.white,
              );
            }
            return const Text(
              'Sign up',
              style: TextStyle(fontSize: 17),
            );
          },
        ),
      ),
    );
  }
}
