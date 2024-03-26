import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:befriend/providers/home_provider.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../models/objects/bubble.dart';
import '../../../../models/objects/friendship.dart';

class SearchButton extends StatefulWidget {
  const SearchButton({
    super.key,
  });

  @override
  State<SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<SearchButton> {
  final TextEditingController _textEditingController = TextEditingController();
  static const double normalPadding = 30;
  static const double friendPadding = normalPadding + 50;

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
        builder: (BuildContext context, HomeProvider provider, Widget? child) {
      return Container(
        alignment: Alignment.bottomCenter,
        margin: const EdgeInsets.only(
            bottom: 60, right: Constants.homeHorizontalPadding),
        child: GestureDetector(
          child: AnimSearchBar(
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
