import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/providers/sign_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpButton extends StatelessWidget {
  const SignUpButton({
    super.key,
    required this.onPressed,
  });

  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return SizedBox(
      width: double.infinity,
      height: 0.050 * height,
      child: ElevatedButton(
        style: const ButtonStyle(
            shape: MaterialStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ))),
        onPressed: onPressed,
        child: Consumer<SignProvider>(
          builder:
              (BuildContext context, SignProvider provider, Widget? child) {
            if (provider.isLoading) {
              return const CircularProgressIndicator();
            }
            return const AutoSizeText(
              'Sign up',
              style: TextStyle(fontSize: 17),
            );
          },
        ),
      ),
    );
  }
}
