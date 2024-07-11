import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:befriend/providers/home_provider.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/objects/bubble.dart';
import '../../../../models/objects/friendship.dart';
import '../../../../utilities/app_localizations.dart';

class SearchButton extends StatefulWidget {
  const SearchButton({
    super.key,
  });

  @override
  State<SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<SearchButton> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    final double normalPadding = 0.067 * width;
    final double friendPadding = normalPadding + 0.11 * width;

    return Consumer<HomeProvider>(
        builder: (BuildContext context, HomeProvider provider, Widget? child) {
      return Container(
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(
            bottom: 0.060 * height,
            right: Constants.homeHorizontalPaddingMultiplier * width),
        child: GestureDetector(
          child: AnimSearchBar(
            helpText: AppLocalizations.of(context)?.translate('sb_text') ??
                "Search...",
            rtl: true,
            width: MediaQuery.of(context).size.width -
                (provider.home.user.main() ? normalPadding : friendPadding),
            onSuffixTap: () {
              setState(() {
                _textEditingController.clear();
              });
            },
            textController: _textEditingController,
            onSubmitted: (String username) {
              // DEVELOP THAT IT GOES TO FRIENDS PROFILE IF NOT IN THE TOP 20 LIST
              username = username.trim();

              for (Friendship friendship in provider.home.user.friendships) {
                if (friendship.friend.username == username) {
                  Bubble searchedBubble = friendship.friend;
                  provider.animateToFriend(context,
                      dx: searchedBubble.x, dy: searchedBubble.y);

                  return;
                }
              }
            },
          ),
        ),
      );
    });
  }
}
