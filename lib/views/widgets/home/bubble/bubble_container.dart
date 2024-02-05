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
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              spreadRadius: 0.5,
              offset: Offset(0, 1),
              blurRadius: 5,
            ),
          ],
        ),
        child: ProfilePhoto(user: user));
  }
}
