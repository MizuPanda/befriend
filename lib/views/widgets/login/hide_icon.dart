import 'package:flutter/material.dart';

class HideIconWidget extends StatefulWidget {
  const HideIconWidget({
    super.key,
    required bool passwordVisible,
    required this.hidePassword,
    required this.size,
  }) : _passwordVisible = passwordVisible;

  final bool _passwordVisible;
  final Function hidePassword;
  final double size;

  @override
  State<HideIconWidget> createState() => _HideIconWidgetState();
}

class _HideIconWidgetState extends State<HideIconWidget> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          widget.hidePassword();
        },
        icon: Icon(
          widget._passwordVisible ? Icons.visibility : Icons.visibility_off,
          color: widget._passwordVisible ? Colors.black : Colors.grey,
          size: widget.size,
        ));
  }
}
