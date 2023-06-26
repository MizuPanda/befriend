import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _hidePassword = true;
  bool _hidePasswordRepeat = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const BefriendTitle(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Welcome! Begin by creating an account',
                          style: GoogleFonts.openSans(
                              textStyle: const TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const IconTextField(
                          iconData: Icons.email, hintText: 'Your email'),
                      const SizedBox(height: 20),
                      const IconTextField(
                          iconData: Icons.person, hintText: 'Your name'),
                      const SizedBox(height: 20),
                      const IconTextField(
                          iconData: Icons.account_circle,
                          hintText: 'Your username'),
                      const SizedBox(height: 20),
                      Stack(
                        children: [
                          IconTextField(
                              iconData: Icons.lock,
                              hintText: 'Your password',
                              hidePassword: _hidePassword),
                          Container(
                            padding: const EdgeInsets.only(top: 3, right: 5),
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _hidePassword = !_hidePassword;
                                  });
                                },
                                icon: Icon(
                                  !_hidePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: !_hidePassword
                                      ? Colors.black
                                      : Colors.grey,
                                  size: 25,
                                )),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Stack(
                        children: [
                          IconTextField(
                              iconData: Icons.lock,
                              hintText: 'Repeat your password',
                              hidePassword: _hidePasswordRepeat),
                          Container(
                            padding: const EdgeInsets.only(top: 3, right: 5),
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _hidePasswordRepeat = !_hidePasswordRepeat;
                                  });
                                },
                                icon: Icon(
                                  !_hidePasswordRepeat
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: !_hidePasswordRepeat
                                      ? Colors.black
                                      : Colors.grey,
                                  size: 25,
                                )),
                          )
                        ],
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: const ButtonStyle(
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ))),
                          onPressed: () {
                            // Handle sign-up button click
                          },
                          child: const Text(
                            'Sign up',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IconTextField extends StatefulWidget {
  final IconData iconData;
  final String hintText;
  final bool? hidePassword;

  const IconTextField(
      {super.key,
      required this.iconData,
      required this.hintText,
      this.hidePassword});

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
      obscureText: widget.hidePassword ?? false,
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
