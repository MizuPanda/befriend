import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:befriend/views/pages/home_page.dart';
import 'package:flutter/cupertino.dart';

import '../../../models/bubble.dart';

class SearchButton extends StatefulWidget {
  const SearchButton({
    super.key, required this.bubble, required this.animate,
  });

  final Bubble bubble;
  final Function(Offset, AnimationType) animate;

  @override
  State<SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<SearchButton> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
          for(Friendship friendship in widget.bubble.friendships) {
            if(friendship.friendBubble.username == username) {
              Bubble searchedBubble = friendship.friendBubble;
              debugPrint('Username:(${searchedBubble.username}, ${searchedBubble.name})');
              debugPrint('${searchedBubble.username}: (${searchedBubble.x}, ${searchedBubble.y})');
              widget.animate(Offset(searchedBubble.x, searchedBubble.y), AnimationType.friend);
              return ;
            }
          }

        },
      ),
    );
  }
}
