import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/providers/forgot_provider.dart';
import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotProvider(),
      child: Consumer(builder:
          (BuildContext context, ForgotProvider provider, Widget? child) {
        final double width = MediaQuery.of(context).size.width;
        final double height = MediaQuery.of(context).size.height;

        return Scaffold(
          appBar: AppBar(
            title: const BefriendTitle(),
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.075),
            child: Stack(
              children: [
                Column(
                  children: [
                    AutoSizeText(
                      'Forgot your password?',
                      style: GoogleFonts.openSans(
                        fontSize: 25,
                      ),
                    ),
                    SizedBox(
                      height: 0.01 * height,
                    ),
                    AutoSizeText(
                      'Please enter the email address used for registration.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(
                          fontSize: 18, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: provider.emailController,
                      focusNode: provider.focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Email',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 0.03 * height),
                    ElevatedButton(
                      onPressed: () {
                        provider.resetPassword(context);
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: provider.isLoading
                            ? const CircularProgressIndicator()
                            : const AutoSizeText(
                                'SUBMIT',
                              ),
                      ),
                    ),
                    SizedBox(height: 0.02 * height),
                    ElevatedButton(
                      onPressed: () {
                        provider.pop(context);
                      },
                      child: const Center(
                          child: Text(
                        'CANCEL',
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
