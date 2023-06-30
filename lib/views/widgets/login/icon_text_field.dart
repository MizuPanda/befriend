import 'package:flutter/material.dart';

class IconTextField extends StatefulWidget {
  final IconData iconData;
  final String hintText;
  final bool? passwordVisible;

  const IconTextField(
      {super.key,
      required this.iconData,
      required this.hintText,
      this.passwordVisible});

  @override
  State<IconTextField> createState() => _IconTextFieldState();
}

class _IconTextFieldState extends State<IconTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: _focusNode,
      onTapOutside: (_) {
        FocusScope.of(context).unfocus();
      },
      style: const TextStyle(fontSize: 18),
      obscureText: !(widget.passwordVisible ?? true),
      decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
          prefixIcon: Icon(widget.iconData),
          prefixIconColor: _isFocused ? Colors.blue : Colors.black,
          hintText: widget.hintText,
          hintStyle: const TextStyle(fontSize: 20),
          border: const OutlineInputBorder(borderSide: BorderSide.none)),
    );
  }
}
