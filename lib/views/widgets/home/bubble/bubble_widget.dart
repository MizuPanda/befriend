import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/providers/home_provider.dart';
import 'package:befriend/views/widgets/users/username_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../models/objects/home.dart';
import '../../../../models/objects/profile.dart';
import 'bubble_container.dart';
import 'bubble_progress_indicator.dart';
import 'friend_level.dart';

class BubbleWidget extends StatelessWidget {
  static const double strokeWidth = 10 / 3;
  static const double textHeight = 25;
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
      return GestureDetector(
        onTap: () {
          GoRouter.of(context).push('/profile',
              extra: Profile(
                  user: specificHome.user, notifyParent: provider.notify));
        },
        child: Center(
          child: SizedBox(
            height: specificHome.user.size + textHeight + 2,
            child: Builder(builder: (context) {
              if (!specificHome.connectedHome) {
                Friendship friendship = specificHome.friendship!;
                return Badge(
                  label: Text(
                    friendship.newPics.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  largeSize: 26,
                  offset: const Offset(0, 0),
                  padding: const EdgeInsets.only(left: 8, right: 7),
                  isLabelVisible: friendship.newPics > 0,
                  child: Builder(builder: (
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
                              textHeight: textHeight,
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
                  }),
                );
              } else {
                return SizedBox(
                  height: specificHome.user.size + textHeight,
                  child: Column(
                    children: [
                      BubbleContainer(user: specificHome.user),
                      UsernameText(
                        user: specificHome.user,
                      ),
                    ],
                  ),
                );
              }
            }),
          ),
        ),
      );
    });
  }
}
