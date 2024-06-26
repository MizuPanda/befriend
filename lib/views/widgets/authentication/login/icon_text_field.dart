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
  final TextInputAction textInputAction;
  final TextInputType textInputType;

  const IconTextField({
    super.key,
    required this.iconData,
    required this.hintText,
    this.passwordVisible,
    this.hidePassword,
    required this.onSaved,
    required this.validator,
    this.onChanged,
    required this.textInputAction,
    required this.textInputType,
  });

  @override
  State<IconTextField> createState() => _IconTextFieldState();
}

class _IconTextFieldState extends State<IconTextField> {
  bool _isFocused = false;
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    focusNode.addListener(() {
      setState(() {
        _isFocused = focusNode.hasFocus;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return BaseFormField(
      action: widget.textInputAction,
      focusNode: focusNode,
      onChanged: widget.onChanged,
      onSaved: widget.onSaved,
      validator: widget.validator,
      keyboardType: widget.passwordVisible == null
          ? widget.textInputType
          : widget.passwordVisible!
              ? TextInputType.visiblePassword
              : widget.textInputType,
      obscureText: !(widget.passwordVisible ?? true),
      decoration: InputDecoration(
          // labelStyle: const TextStyle(fontSize: 18),
          contentPadding: EdgeInsets.symmetric(
              vertical: 30 / 448 * width, horizontal: 0.01 * height),
          prefixIcon: Icon(widget.iconData),
          prefixIconColor: _isFocused
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).primaryColor,
          suffixIcon: widget.passwordVisible != null
              ? HideIconButton(
                  passwordVisible: widget.passwordVisible!,
                  hidePassword: widget.hidePassword!,
                )
              : null,
          hintText: widget.hintText,
          // hintStyle: const TextStyle(fontSize: 20),
          border: const OutlineInputBorder(borderSide: BorderSide.none)),
    );
  }
}
