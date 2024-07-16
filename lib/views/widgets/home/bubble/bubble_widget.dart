import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/objects/home.dart';
import 'bubble_container.dart';
import 'bubble_progress_indicator.dart';

class BubbleWidget extends StatelessWidget {
  const BubbleWidget({
    super.key,
    required this.specificHome,
  });

  final Home specificHome;

  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (BuildContext context, HomeProvider provider, Widget? child) {
      if (!specificHome.connectedHome && provider.home.connectedHome) {
        Friendship friendship = specificHome.friendship!;
        return Stack(
          children: [
            BubbleContainer(user: specificHome.user),
            BubbleProgressIndicator(friendship: friendship),
            BubbleGradientIndicator(friendship: friendship),
          ],
        );
      } else {
        return BubbleContainer(user: specificHome.user);
      }
    });
  }
}
