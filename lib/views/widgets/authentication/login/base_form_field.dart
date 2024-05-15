import 'package:flutter/material.dart';

class BaseFormField extends StatelessWidget {
  const BaseFormField({
    Key? key,
    required this.focusNode,
    this.onChanged,
    required this.onSaved,
    required this.validator,
    required this.keyboardType,
    required this.obscureText,
    required this.decoration,
    required this.action,
    this.controller,
  }) : super(key: key);

  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final InputDecoration decoration;
  final TextInputAction action;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: action,
      focusNode: focusNode,
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: decoration,
    );
  }
}
