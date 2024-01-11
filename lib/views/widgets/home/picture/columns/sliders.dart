import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../models/data/data_manager.dart';
import '../../../../../models/objects/bubble.dart';
import '../../../../../providers/hosting_provider.dart';
import '../../../../../utilities/constants.dart';
import '../../../users/profile_photo.dart';

class UserSlidersScreen extends StatelessWidget {
  const UserSlidersScreen({
    super.key,
    required this.ids,
  });
  final List<String> ids;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Constants.usersCollection
            .where(FieldPath.documentId, whereIn: ids)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          return ListView(
            children: snapshot.data!.docs.map((userDocument) {
              return UserSlider(
                userDocument: userDocument,
              );
            }).toList(),
          );
        });
  }
}

class UserSlider extends StatefulWidget {
  final QueryDocumentSnapshot userDocument;

  const UserSlider({
    super.key,
    required this.userDocument,
  });

  @override
  State<UserSlider> createState() => _UserSliderState();
}

class _UserSliderState extends State<UserSlider> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double sliderValue =
        DataManager.getNumber(widget.userDocument, Constants.sliderDoc)
            .toDouble();

    return Consumer(builder:
        (BuildContext context, HostingProvider provider, Widget? child) {
      Bubble bubble = provider.bubbleFromId(widget.userDocument.id);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          children: [
            ProfilePhoto(
              user: bubble,
              radius: Constants.pictureDialogAvatarSize,
            ),
            const SizedBox(
                width: 16.0), // For spacing between the photo and text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bubble.name,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(
                    height: 4.0), // For spacing between the name and username
                Text(bubble.username,
                    style: const TextStyle(fontSize: 14.0, color: Colors.grey)),
              ],
            ),
            Expanded(
              child: Slider(
                value: sliderValue,
                min: 0,
                max: 100,
                divisions: 100,
                onChangeEnd: provider.isUser(bubble.id)
                    ? (newValue) {
                        widget.userDocument.reference
                            .update({Constants.sliderDoc: newValue});
                      }
                    : null,
                onChanged: (double value) {
                  setState(() {
                    sliderValue = value;
                  });
                },
              ),
            )
          ],
        ),
      );
    });
  }
}
