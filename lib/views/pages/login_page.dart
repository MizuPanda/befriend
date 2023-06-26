import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final FocusNode _emailFocusNode = FocusNode();
  bool _isEmailFocused = false;

  final FocusNode _passwordFocusNode = FocusNode();
  bool _isPasswordFocused = false;

  bool _passwordVisible = false;

  void hidePassword() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  void initState() {
    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
      });
    });
    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            const SafeArea(
                child: Align(
                    alignment: Alignment.topCenter,
                    child: BefriendTitle(
                      fontSize: 50,
                    ))),
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    onTapOutside: (_) {
                      _unfocus();
                    },
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _emailFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Enter your email',
                      labelStyle: TextStyle(
                        color: _isEmailFocused ? Colors.blue : Colors.black,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(
                          color: _isEmailFocused ? Colors.blue : Colors.black,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.black, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Stack(
                    children: [
                      TextFormField(
                        focusNode: _passwordFocusNode,
                        onTapOutside: (_) {
                            _unfocus();
                        },
                        obscureText: !_passwordVisible,
                        keyboardType: _passwordVisible? TextInputType.visiblePassword: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Enter your password',
                          labelStyle: TextStyle(
                            color: _isPasswordFocused ? Colors.blue : Colors.black,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                              color: _isPasswordFocused ? Colors.blue : Colors.black,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(color: Colors.black, width: 1.5),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 3,right: 5),
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                            onPressed: () {
                              hidePassword();
                            },
                            icon: Icon(
                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
                              color: _passwordVisible ? Colors.black : Colors.grey,
                              size: 25,
                            )),
                      )
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          // Handle sign up button pressed
                        },
                        child: const Text('Sign up'),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          // Handle login button pressed
                        },
                        style: const ButtonStyle(
                          enableFeedback: true
                        ),
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Handle forgot password button pressed
                      },
                      child: const Text('Forgot your password?'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();

  static InputDecoration style({String hintText = ""}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(12),
      hintText: hintText,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
      ),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black, width: 2.0)),
    );
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;

  bool _passwordVisible = false;

  void hidePassword() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 45, right: 45),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BefriendTitle(fontSize: 40,),
              const SizedBox(height: 16,),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 70,
                      child: TextFormField(
                        style: const TextStyle(fontSize: 30),
                        keyboardType: TextInputType.emailAddress,
                        autofocus: false,
                        onSaved: (value) {
                          email = value;
                        },
                        validator: (value) {
                          return null;
                        },
                        decoration: LoginPage.style(
                          hintText: "Enter your email",
                        ),
                      ),
                    ),
                    const SizedBox(height: 16,),
                    Stack(
                      children: [
                        Container(
                          color: Colors.red,
                          height: 70,
                          child: TextFormField(
                            style: const TextStyle(fontSize: 25),
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (String? password) {

                            },
                            validator: (value) {
                              return null;
                            },
                            decoration: LoginPage.style(hintText: "Enter your password"),
                            obscureText: !_passwordVisible,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 5),
                          alignment: Alignment.centerRight,
                          child: IconButton(
                              onPressed: () {
                                hidePassword();
                              },
                              icon: Icon(
                                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                color: _passwordVisible ? Colors.black : Colors.grey,
                                size: 30,
                              )),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15.0),
                                side: const BorderSide(
                                    color: Colors.black, width: 1.0)))),
                    onPressed: () {},
                    child: const Text("Create an account"),
                  ),
                  TextButton(
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(15.0),
                                side: const BorderSide(
                                    color: Colors.black, width: 1.0)))),
                    onPressed: () {},
                    child: const Text("Create an account"),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Forgot my password",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordLoginField extends StatefulWidget {
  final Function(String?) onSaved;

  const PasswordLoginField({Key? key, required this.onSaved}) : super(key: key);

  @override
  State<PasswordLoginField> createState() => _PasswordLoginFieldState();
}

class _PasswordLoginFieldState extends State<PasswordLoginField> {
  bool _passwordVisible = false;

  void hidePassword() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 70,
          child: TextFormField(
            style: const TextStyle(fontSize: 25),
            keyboardType: TextInputType.emailAddress,
            onSaved: widget.onSaved,
            validator: (value) {
              return null;
            },
            decoration: LoginPage.style(hintText: "Enter your password"),
            obscureText: !_passwordVisible,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(right: 5),
          alignment: Alignment.centerRight,
          child: IconButton(
              onPressed: () {
                hidePassword();
              },
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: _passwordVisible ? Colors.black : Colors.grey,
                size: 25,
              )),
        )
      ],
    );
  }
}
*/
