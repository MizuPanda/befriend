import 'package:flutter/material.dart';

import '../../../models/bubble_user.dart';

class ProfilePhoto extends StatelessWidget {
  final double? radius;
  const ProfilePhoto({
    super.key,
    this.radius, required this.user,
  });

  final BubbleUser user;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius ?? user.bubble().size/2,
      backgroundImage: user.bubble().avatar,
    );
  }
}
