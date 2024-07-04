import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/providers/material_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/picture_sign_provider.dart';
import '../../utilities/app_localizations.dart';

class PictureSignPage extends StatelessWidget {
  const PictureSignPage({super.key});
  static const double _avatarLengthMultiplier = 0.35;
  static const double _heightMultiplier = 0.01;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      child: ChangeNotifierProvider(
          create: (_) => PictureSignProvider(),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                AppLocalizations.of(context)?.translate('psp_ls')??'Last step',
                style: GoogleFonts.openSans(),
              ),
              centerTitle: true,
            ),
            body: Consumer(builder: (BuildContext context,
                PictureSignProvider provider, Widget? child) {
              return Consumer(builder: (BuildContext context,
                  MaterialProvider materialProvider, Widget? child) {
                final bool lightMode = materialProvider.isLightMode(context);

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: width * _avatarLengthMultiplier,
                        height: width * _avatarLengthMultiplier,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 3,
                              color: lightMode ? Colors.black : Colors.white),
                        ),
                        child: provider.imageNull()
                            ? Icon(
                                Icons.camera_alt_outlined,
                                size: width * 0.12,
                              )
                            : CircleAvatar(
                                radius: width * _avatarLengthMultiplier,
                                backgroundImage: provider.image()),
                      ),
                      SizedBox(height: _heightMultiplier * 3 * height),
                      AutoSizeText(AppLocalizations.of(context)?.translate('psp_almost')??'Almost Done!',
                          style: GoogleFonts.openSans(
                            textStyle: const TextStyle(
                              fontSize: 40.0,
                              //fontWeight: FontWeight.bold,
                            ),
                          )),
                      SizedBox(height: _heightMultiplier * height),
                      Container(
                        width: 10.0,
                        height: 10.0,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: lightMode ? Colors.black : Colors.white),
                      ),
                      SizedBox(height: _heightMultiplier * height),
                      Container(
                        width: 0.45 * width,
                        padding: EdgeInsets.symmetric(
                          vertical: _heightMultiplier * height,
                          horizontal: width * 0.03,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          border: Border.all(
                              width: 3,
                              color: lightMode ? Colors.black : Colors.white),
                        ),
                        child: AutoSizeText(
                            AppLocalizations.of(context)?.translate('psp_add')??'Add a photo to personalize your profile.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                fontSize: 20.0,
                              ),
                            )),
                      ),
                      SizedBox(height: _heightMultiplier * 2 * height),
                      ElevatedButton(
                        style: ButtonStyle(
                            shape:
                                WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                            padding: WidgetStatePropertyAll(
                                EdgeInsets.symmetric(
                                    horizontal: 0.12 * width,
                                    vertical:
                                        1.5 * _heightMultiplier * height))),
                        onPressed: () async {
                          await provider.retrieveImage(context);
                        },
                        child: AutoSizeText(AppLocalizations.of(context)?.translate('psp_capture')??'Capture Photo'),
                      ),
                      SizedBox(
                        height: _heightMultiplier * height,
                      ),
                      SizedBox(
                        width: 0.55 * width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                                onPressed: () async {
                                  await provider.skipHome(context);
                                },
                                child: Center(
                                  child: provider.isSkipLoading
                                      ? const CircularProgressIndicator()
                                      :  AutoSizeText(
                                    AppLocalizations.of(context)?.translate('general_word_skip')??'Skip',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                )),
                            TextButton(
                                onPressed: provider.imageNull()
                                    ? null
                                    : () async {
                                        await provider.continueHome(context);
                                      },
                                child: Center(
                                  child: provider.isContinueLoading
                                      ? const CircularProgressIndicator()
                                      : AutoSizeText(
                                    AppLocalizations.of(context)?.translate('general_word_confirm')??'Confirm',
                                          style: TextStyle(
                                              color: provider.imageNull()
                                                  ? Colors.grey
                                                  : null,
                                              fontSize: 16),
                                        ),
                                ))
                          ],
                        ),
                      )
                    ],
                  ),
                );
              });
            }),
          )),
    );
  }
}
