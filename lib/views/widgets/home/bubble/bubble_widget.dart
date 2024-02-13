import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/providers/home_provider.dart';
import 'package:befriend/views/widgets/users/username_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/objects/home.dart';
import 'bubble_container.dart';
import 'bubble_progress_indicator.dart';
import 'friend_level.dart';

class BubbleWidget extends StatelessWidget {
  static const double levelHeight = 25;

  const BubbleWidget({
    Key? key,
    required this.specificHome,
  }) : super(key: key);

  final Home specificHome;

  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (BuildContext context, HomeProvider provider, Widget? child) {
      return Builder(builder: (context) {
        if (!specificHome.connectedHome) {
          Friendship friendship = specificHome.friendship!;
          return Builder(builder: (
            BuildContext context,
          ) {
            if (provider.home.connectedHome) {
              return Stack(
                children: [
                  Column(
                    children: [
                      Stack(children: [
                        BubbleContainer(user: specificHome.user),
                        BubbleProgressIndicator(friendship: friendship),
                        BubbleGradientIndicator(friendship: friendship),
                      ]),
                      UsernameText(user: specificHome.user),
                    ],
                  ),
                  FriendLevelWidget(
                      specificHome: specificHome,
                      levelHeight: levelHeight,
                      friendship: friendship)
                ],
              );
            } else {
              return Column(
                children: [
                  BubbleContainer(user: specificHome.user),
                  UsernameText(user: specificHome.user),
                ],
              );
            }
          });
        } else {
          return Column(
            children: [
              BubbleContainer(user: specificHome.user),
              UsernameText(
                user: specificHome.user,
              ),
            ],
          );
        }
      });
    });
  }
}
