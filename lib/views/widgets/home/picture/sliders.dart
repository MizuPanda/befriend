import 'package:befriend/providers/session_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../models/objects/bubble.dart';
import '../../../../../utilities/constants.dart';
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

            return ListView(
              children: snapshot.data!.docs.map((userDocument) {
                return UserSlider(
                  bubble: provider.bubble(userDocument.id)!,
                  sliderValue: provider.sliderValue(userDocument.id),
                  reference: userDocument.reference,
                );
              }).toList(),
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

  @override
  void initState() {
    sliderValue = widget.sliderValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(builder:
        (BuildContext context, SessionProvider provider, Widget? child) {
      if (!provider.isUser(widget.bubble.id)) {
        sliderValue = widget.sliderValue;
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          children: [
            ProfilePhoto(
              user: widget.bubble,
              radius: Constants.pictureDialogAvatarSize,
            ),
            const SizedBox(
                width: 16.0), // For spacing between the photo and text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.bubble.name,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(
                    height: 4.0), // For spacing between the name and username
                Text(widget.bubble.username,
                    style: const TextStyle(fontSize: 14.0, color: Colors.grey)),
              ],
            ),
            Expanded(
              child: Column(
                children: [
                  Slider(
                    value: sliderValue,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    onChanged: provider.isUser(widget.bubble.id)
                        ? (double value) {
                            setState(() {
                              sliderValue = value;
                            });
                          }
                        : null,
                    onChangeEnd: provider.isUser(widget.bubble.id)
                        ? (double value) async {
                            // Debounce logic here if needed
                            await widget.reference
                                .update({Constants.sliderDoc: value});
                          }
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Public',
                          style: GoogleFonts.openSans(
                              fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                        const Spacer(),
                        Text(
                          'Private',
                          style: GoogleFonts.openSans(
                              fontSize: 12, fontStyle: FontStyle.italic),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}
