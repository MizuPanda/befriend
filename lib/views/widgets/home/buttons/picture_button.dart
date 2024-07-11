import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/providers/material_provider.dart';
import 'package:befriend/providers/picture_button_provider.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../utilities/app_localizations.dart';

class PictureButton extends StatefulWidget {
  const PictureButton({
    super.key,
    required this.three,
  });

  @override
  State<PictureButton> createState() => _PictureButtonState();

  final GlobalKey three;
}

class _PictureButtonState extends State<PictureButton> {
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
        create: (_) => PictureButtonProvider(),
        builder: (BuildContext context, Widget? child) {
          return Consumer<PictureButtonProvider>(builder: (BuildContext context,
              PictureButtonProvider provider, Widget? child) {
            return AnimatedPositioned(
              right: -provider.dragPosition,
              left: provider.dragPosition,
              bottom: 0.012 * height,
              duration: const Duration(
                  milliseconds: 300), // Keeps the button at the bottom
              child: GestureDetector(
                onHorizontalDragUpdate: provider.onHorizontalDragUpdate,
                onHorizontalDragEnd: provider.onHorizontalDragEnd,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          width * Constants.homeHorizontalPaddingMultiplier),
                  child: Consumer(builder: (BuildContext context,
                      MaterialProvider materialProvider, Widget? child) {
                    final bool lightMode =
                        materialProvider.isLightMode(context);

                    return Showcase(
                      key: widget.three,
                      description: AppLocalizations.of(context)
                              ?.translate('pb_three') ??
                          'Swipe here to switch between Host and Join mode.',
                      child: Container(
                        width: width,
                        height: 0.054 * height,
                        decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: provider.isJoinMode
                                  ? (lightMode
                                      ? const [
                                          Color.fromRGBO(203, 98, 98, 1.0),
                                          Color.fromRGBO(213, 18, 18, 1.0),
                                          Color.fromRGBO(203, 98, 98, 1.0),
                                        ]
                                      : const [
                                          Color.fromRGBO(138, 67, 67, 1.0),
                                          Color.fromRGBO(155, 15, 15, 1.0),
                                          Color.fromRGBO(138, 67, 67, 1.0),
                                        ])
                                  : (lightMode
                                      ? const [
                                          Color.fromRGBO(109, 130, 208, 1.0),
                                          Color.fromRGBO(0, 73, 243, 1.0),
                                          Color.fromRGBO(109, 130, 208, 1.0),
                                        ]
                                      : const [
                                          Color.fromRGBO(76, 102, 141, 1.0),
                                          Color.fromRGBO(0, 49, 171, 1.0),
                                          Color.fromRGBO(76, 102, 141, 1.0),
                                        ]),
                              radius: 20,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(25.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: provider.isJoinMode
                                    ? const Color.fromRGBO(213, 18, 18, 1.0)
                                        .withOpacity(0.2)
                                    : const Color.fromRGBO(0, 73, 243, 1.0)
                                        .withOpacity(0.2),
                                spreadRadius: 4,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              )
                            ]),
                        child: GestureDetector(
                          onTap: () async {
                            await provider.onPressed(context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: provider.dragPosition > 50
                                        ? 22.0 / 448 * width
                                        : 0),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.keyboard_double_arrow_left_rounded,
                                    color: Colors.white,
                                  ),
                                  onPressed: provider.switchMode,
                                ),
                              ),
                              AutoSizeText(
                                provider.isJoinMode
                                    ? AppLocalizations.of(context)
                                            ?.translate('pb_join') ??
                                        'Join a picture'
                                    : AppLocalizations.of(context)
                                            ?.translate('pb_take') ??
                                        'Take a picture',
                                style: GoogleFonts.openSans(
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 26,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: provider.dragPosition < -50
                                          ? 22 / 448 * width
                                          : 0),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.keyboard_double_arrow_right_rounded,
                                      color: Colors.white,
                                    ),
                                    onPressed: provider.switchMode,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          });
        });
  }
}
