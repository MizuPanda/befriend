import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/providers/sign_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/app_localizations.dart';
import '../../../../utilities/password_strength.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    super.key,
  });

  static const double _leftPaddingMultiplier = 15 / 448;

  @override
  Widget build(BuildContext context) {
    return Consumer<SignProvider>(
        builder: (BuildContext context, SignProvider provider, Widget? child) {
      final Color indicatorColor;
      final String text;
      final double strength = provider.strength();

      final double width = MediaQuery.of(context).size.width;
      final double height = MediaQuery.of(context).size.height;

      if (provider.isPasswordEmpty()) {
        indicatorColor = Colors.transparent;
        text = '';
      } else if (strength <= 2) {
        indicatorColor = Colors.red;
        text = AppLocalizations.of(context)?.translate('si_weak')??'Weak';
      } else if (strength <= 3) {
        indicatorColor = Colors.orange;
        text = AppLocalizations.of(context)?.translate('si_medium')??'Medium';
      } else {
        indicatorColor = Colors.green;
        text = AppLocalizations.of(context)?.translate('si_strong')??'Strong';
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 0.010 * height,
            margin: EdgeInsets.symmetric(
                horizontal: _leftPaddingMultiplier * width),
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
            padding: EdgeInsets.only(left: _leftPaddingMultiplier * width),
            child: AutoSizeText(
              text,
              style: TextStyle(color: indicatorColor),
            ),
          ),
        ],
      );
    });
  }
}
