import 'package:befriend/providers/sign_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utilities/password_strength.dart';

class PasswordStrengthIndicator extends StatefulWidget {
  const PasswordStrengthIndicator({
    super.key,
  });

  @override
  State<PasswordStrengthIndicator> createState() =>
      _PasswordStrengthIndicatorState();
}

class _PasswordStrengthIndicatorState extends State<PasswordStrengthIndicator> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SignProvider>(
        builder: (BuildContext context, SignProvider provider, Widget? child) {
      Color indicatorColor;
      String text;
      final double strength = provider.strength();

      if (strength <= 2) {
        indicatorColor = Colors.red;
        text = 'Weak';
      } else if (strength <= 3) {
        indicatorColor = Colors.orange;
        text = 'Medium';
      } else {
        indicatorColor = Colors.green;
        text = 'Strong';
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey[300],
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: strength == 0 ? 1 : strength / PasswordStrength.max,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: strength == 0 ? Colors.transparent : indicatorColor,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              text,
              style: TextStyle(color: indicatorColor),
            ),
          ),
        ],
      );
    });
  }
}
