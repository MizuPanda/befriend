import 'package:flutter/material.dart';

import 'base_form_field.dart';
import 'hide_icon.dart';

class IconTextField extends StatefulWidget {
  final IconData iconData;
  final String hintText;
  final bool? passwordVisible;
  final Function? hidePassword;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const IconTextField(
      {super.key,
      required this.iconData,
      required this.hintText,
      this.passwordVisible,
      this.hidePassword,
      required this.onSaved,
      required this.validator,
      this.onChanged});

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
    return BaseTextField(
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      onSaved: (String? s) {},
      validator: (String? s) {
        return null;
      },
      keyboardType: widget.passwordVisible == null
          ? TextInputType.text
          : widget.passwordVisible!
              ? TextInputType.visiblePassword
              : TextInputType.text,
      obscureText: !(widget.passwordVisible ?? true),
      decoration: InputDecoration(
          labelStyle: const TextStyle(fontSize: 18),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
          prefixIcon: Icon(widget.iconData),
          prefixIconColor: _isFocused ? Colors.blue : Colors.black,
          suffixIcon: widget.passwordVisible != null
              ? HideIconButton(
                  passwordVisible: widget.passwordVisible!,
                  hidePassword: widget.hidePassword!,
                )
              : null,
          hintText: widget.hintText,
          hintStyle: const TextStyle(fontSize: 20),
          border: const OutlineInputBorder(borderSide: BorderSide.none)),
    );
  }
}
