import 'package:befriend/models/objects/friendship_progress.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../objects/friendship.dart';

class FriendManager {
  static Future<DocumentSnapshot> getData(
      String userID, String friendID) async {
    List<String> ids = [userID, friendID];
    ids.sort();
    String docID = ids.first + ids.last;
    return await Constants.friendshipsCollection.doc(docID).get();
  }

  static Future<void> setFriendship(Friendship friendship) async {
    final DocumentReference docRef =
        Constants.friendshipsCollection.doc(friendship.friendshipID);
    await docRef.set(
      friendship.toMap(),
    );
  }

  static Future<Map<String, List<FriendshipProgress>>> fetchFriendshipsForUsers(
      List<String> userIds) async {
    Map<String, List<FriendshipProgress>> userFriendshipsMap = {};

    for (String userId in userIds) {
      List<FriendshipProgress> friendships =
          await _fetchUserFriendships(userId, userIds);
      userFriendshipsMap[userId] = friendships;
    }

    return userFriendshipsMap;
  }

  static Future<List<FriendshipProgress>> _fetchUserFriendships(
      String userId, List<String> sessionUsers) async {
    List<FriendshipProgress> friendships = [];

    // Fetch friendships where the user is either user1 or user2

    QuerySnapshot query = await Constants.friendshipsCollection
        .where(Filter.or(
          Filter('${Constants.userDoc}1', isEqualTo: userId),
          Filter('${Constants.userDoc}2', isEqualTo: userId),
        ))
        .get();

    for (DocumentSnapshot doc in query.docs) {
      FriendshipProgress progress = FriendshipProgress.fromDocs(doc, userId);
      //debugPrint('(FriendManager): User ${progress.friendUsername()}');
      if (!sessionUsers.contains(progress.friendId())) {
        friendships.add(progress);
      }
    }

    return friendships;
  }

  static Future<void> deleteFriendship(String friendshipId) async {
    await FirebaseFirestore.instance
        .collection('friendships')
        .doc(friendshipId)
        .delete();
  }
}
