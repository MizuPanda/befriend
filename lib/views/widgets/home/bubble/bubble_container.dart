import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/objects/bubble.dart';
import '../../../../providers/material_provider.dart';
import '../../users/profile_photo.dart';

class BubbleContainer extends StatelessWidget {
  const BubbleContainer({
    super.key,
    required this.user,
  });

  final Bubble user;

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (BuildContext context,
        MaterialProvider materialProvider, Widget? child) {
      return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: materialProvider.isLightMode(context)
                    ? Colors.black
                    : Colors.white70,
                spreadRadius: 0.5,
                offset: const Offset(0, 1),
                blurRadius: 5,
              ),
            ],
          ),
          child: ProfilePhoto(user: user));
    });
  }
}
