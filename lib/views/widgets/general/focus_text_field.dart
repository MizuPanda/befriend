import 'package:flutter/material.dart';

class FocusTextField extends StatelessWidget {
  const FocusTextField({
    Key? key,
    required this.focusNode,
    required this.keyboardType,
    required this.decoration,
    this.controller,
  }) : super(key: key);

  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final InputDecoration decoration;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onTapOutside: (_) {
        FocusScope.of(context).unfocus();
      },
      keyboardType: keyboardType,
      decoration: decoration,
    );
  }
}
