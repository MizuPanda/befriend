import 'package:flutter/material.dart';

class BaseTextField extends StatelessWidget {
  const BaseTextField({
    Key? key,
    required this.focusNode,
    this.onChanged,
    required this.onSaved,
    required this.validator,
    required this.keyboardType,
    required this.obscureText,
    required this.decoration,
  }) : super(key: key);

  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final InputDecoration decoration;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      onTapOutside: (_) {
        FocusScope.of(context).unfocus();
      },
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: decoration,
    );
  }
}
