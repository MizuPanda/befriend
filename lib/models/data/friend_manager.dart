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
    QuerySnapshot querySnapshot1 = await Constants.friendshipsCollection
        .where('${Constants.userDoc}1', isEqualTo: userId, whereNotIn: sessionUsers)
        .get();

    QuerySnapshot querySnapshot2 = await Constants.friendshipsCollection
        .where('${Constants.userDoc}2', isEqualTo: userId, whereNotIn: sessionUsers)
        .get();

    for (DocumentSnapshot doc in querySnapshot1.docs) {
      FriendshipProgress progress = FriendshipProgress.fromDocs(doc);
      friendships.add(progress);
    }

    for (DocumentSnapshot doc in querySnapshot2.docs) {
      FriendshipProgress progress = FriendshipProgress.fromDocs(doc);
      friendships.add(progress);
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
