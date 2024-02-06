import 'package:befriend/models/objects/friendship.dart';

import 'bubble.dart';

class Profile {
  Bubble user;
  Friendship? friendship;
  Function notifyParent;

  Profile(
      {required this.user,
      required this.friendship,
      required this.notifyParent});

  String levelText() {
    return user.main()
        ? 'Social Level: ${user.power}'
        : 'Relationship Level: ${friendship!.level}';
  }
}
