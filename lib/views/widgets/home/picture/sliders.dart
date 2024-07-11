import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/providers/session_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../../models/objects/bubble.dart';
import '../../../../../utilities/constants.dart';
import '../../../../utilities/app_localizations.dart';
import '../../users/profile_photo.dart';

class UserSlidersScreen extends StatelessWidget {
  const UserSlidersScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(builder:
        (BuildContext context, SessionProvider provider, Widget? child) {
      return StreamBuilder(
          stream: Constants.usersCollection
              .where(FieldPath.documentId, whereIn: provider.ids)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();

            provider.processSnapshot(snapshot.data!, context);

            return Showcase(
              key: provider.three,
              description: AppLocalizations.of(context)?.translate('s_three') ??
                  'Slide to select who you allow to see the picture.',
              child: ListView(
                children: snapshot.data!.docs.map((userDocument) {
                  return UserSlider(
                    bubble: provider.bubble(userDocument.id)!,
                    sliderValue: provider.sliderValue(userDocument.id),
                    reference: userDocument.reference,
                  );
                }).toList(),
              ),
            );
          });
    });
  }
}

class UserSlider extends StatefulWidget {
  final Bubble bubble;
  final double sliderValue;
  final DocumentReference reference;

  const UserSlider({
    super.key,
    required this.bubble,
    required this.sliderValue,
    required this.reference,
  });

  @override
  State<UserSlider> createState() => _UserSliderState();
}

class _UserSliderState extends State<UserSlider> {
  double sliderValue = 0;
  static const _horizontalPaddingMultiplier = 1 / 28;

  @override
  void initState() {
    sliderValue = widget.sliderValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Consumer<SessionProvider>(builder:
        (BuildContext context, SessionProvider provider, Widget? child) {
      if (!provider.isUser(widget.bubble.id)) {
        sliderValue = widget.sliderValue;
      }
      return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: _horizontalPaddingMultiplier * width,
            vertical: 0.010 * height),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor,
                        spreadRadius: 0.5,
                        offset: const Offset(0, 1),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: ProfilePhoto(
                    user: widget.bubble,
                    radius: Constants.pictureDialogAvatarSize,
                  ),
                ),
                SizedBox(
                    width: _horizontalPaddingMultiplier *
                        width), // For spacing between the photo and text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(widget.bubble.username,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                Builder(builder: (context) {
                  if (provider.isUser(widget.bubble.id)) {
                    debugPrint('(Sliders) ${provider.pointsLength() - 1}');
                    debugPrint(
                        '(Sliders) Critical Points= ${provider.criticalPoints()}');

                    return Slider(
                      value: provider.selectedIndex.toDouble(),
                      min: 0.0,
                      max: provider.pointsLength() - 1,
                      divisions: provider.pointsLength() - 1,
                      onChanged: (double value) {
                        setState(() {
                          provider.selectedIndex = value.toInt();
                          debugPrint("(Sliders) Selected privacy = $value");
                        });
                      },
                      onChangeEnd: (double value) async {
                        // Debounce logic here if needed
                        await widget.reference
                            .update({Constants.sliderDoc: provider.getPoint()});
                      },
                    );
                  } else {
                    return Slider(
                      value: sliderValue,
                      min: 0.0,
                      max: 1.0,
                      divisions: 100,
                      onChanged: null,
                    );
                  }
                }),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: _horizontalPaddingMultiplier * width),
                      child: AutoSizeText(
                        AppLocalizations.of(context)?.translate('s_public') ??
                            'Public',
                        style: GoogleFonts.openSans(
                            fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.only(
                          right: _horizontalPaddingMultiplier * width),
                      child: AutoSizeText(
                        AppLocalizations.of(context)?.translate('s_private') ??
                            'Private',
                        style: GoogleFonts.openSans(
                            fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      );
    });
  }
}
