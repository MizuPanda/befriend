import 'package:flutter/material.dart';

import '../../../../models/objects/bubble.dart';
import '../../users/profile_photo.dart';

class BubbleContainer extends StatelessWidget {
  const BubbleContainer({
    super.key,
    required this.user,
  });

  final Bubble user;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        child: ProfilePhoto(user: user));
  }
}
