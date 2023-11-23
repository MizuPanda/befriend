import 'package:flutter/material.dart';

import '../../../models/objects/bubble.dart';

class ProfilePhoto extends StatelessWidget {
  final double? radius;

  const ProfilePhoto({
    super.key,
    this.radius,
    required this.user,
  });

  final Bubble user;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius ?? user.size / 2,
      backgroundImage: user.avatar,
    );
  }
}
