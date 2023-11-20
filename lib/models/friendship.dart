import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'bubble.dart';

class Friendship {
  Bubble friend;
  int level;
  double progress;
  int newPics;
  final int userIndex;
  final List<String> ids;

  Friendship({
    required this.friend,
    required this.level,
    required this.progress,
    required this.newPics,
    required this.userIndex,
    required this.ids
  });

  factory Friendship.fromDocs(String mainID, Bubble friendBubble, DocumentSnapshot docs) {
    String data = docs.data().toString();

    List<String> ids = [mainID, friendBubble.id];
    ids.sort();
    int userIndex = ids.indexOf(mainID);


    return Friendship(
        friend: friendBubble,
        level: data.contains(Constants.levelDoc)? docs.get(Constants.levelDoc): -1,
        progress: data.contains(Constants.progressDoc)? docs.get(Constants.progressDoc): -1,
        newPics: data.contains(Constants.newPics(userIndex))? docs.get(Constants.newPics(userIndex)): -1,
        userIndex: userIndex,
        ids: ids);
  }

  double distance() {
    return 150 / (level.toDouble() + progress / 100);
  }


  /// docId returns the id of the friendship document.
  /// The id is the concatenation of the two user ids.
  /// The two user ids are sorted alphabetically.
  String docId() {
    return ids.first + ids.last;
  }
}
