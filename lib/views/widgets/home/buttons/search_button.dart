import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:befriend/providers/home_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
        builder: (BuildContext context, HomeProvider provider, Widget? child) {
      return Container(
        alignment: Alignment.bottomCenter,
        margin: const EdgeInsets.only(bottom: 60, right: 15),
        child: AnimSearchBar(
          rtl: true,
          width: MediaQuery.of(context).size.width - 30,
          onSuffixTap: () {
            setState(() {
              _textEditingController.clear();
            });
          },
          textController: _textEditingController,
          onSubmitted: (String username) {
            for (Friendship friendship in provider.home.user().friendships) {
              if (friendship.friend.username == username ||
                  friendship.friend.name == username) {
                Bubble searchedBubble = friendship.friend;
                provider.animateToFriend(
                  Offset(searchedBubble.x, searchedBubble.y),
                );
                return;
              }
            }
          },
        ),
      );
    });
  }
}
