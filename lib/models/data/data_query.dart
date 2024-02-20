import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/objects/bubble.dart';
import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DataQuery {
  static const int _friendsLimit = 20;
  static Future<void> updateDocument(String docId, dynamic data) async {
    await Constants.usersCollection
        .doc(AuthenticationManager.id())
        .update(<String, dynamic>{docId: data});
  }

  static Future<Friendship> getFriendship(
      String currentUserID, String otherUserID) async {
    List<String> ids = [currentUserID, otherUserID];
    ids.sort();
    String friendshipID = ids.first + ids.last;

    DocumentSnapshot friendshipSnap =
        await Constants.friendshipsCollection.doc(friendshipID).get();
    DocumentSnapshot bubbleSnap = await DataManager.getData(id: otherUserID);
    ImageProvider avatar = await DataManager.getAvatar(bubbleSnap);

    Bubble friendBubble = Bubble.fromDocsWithoutFriends(bubbleSnap, avatar);
    return Friendship.fromDocs(currentUserID, friendBubble, friendshipSnap);
  }

  static Future<List<Friendship>> friendList(
      String userID, List<dynamic> friendIDs) async {
    final List<Friendship> friendships = [];
    final String mainID = AuthenticationManager.id();

    QuerySnapshot query = await Constants.friendshipsCollection
        .where(Filter.or(
          Filter(Constants.user1Doc, isEqualTo: userID),
          Filter(Constants.user2Doc, isEqualTo: userID),
        ))
        .orderBy(Constants.levelDoc, descending: true)
        .limit(_friendsLimit)
        .get();

    for (QueryDocumentSnapshot doc in query.docs) {
      Bubble friend;
      Friendship friendship;
      String friendID;
      String user1 = DataManager.getString(doc, Constants.user1Doc);
      String user2 = DataManager.getString(doc, Constants.user2Doc);
      if (user1 == userID) {
        friendID = user2;
      } else {
        friendID = user1;
      }

      if (mainID != userID && friendID == mainID) {
        friend = await UserManager.getInstance();
      } else {
        DocumentSnapshot friendDocs = await DataManager.getData(id: friendID);
        ImageProvider avatar = await DataManager.getAvatar(friendDocs);

        friend = Bubble.fromDocsWithoutFriends(friendDocs, avatar);
      }

      friendship = Friendship.fromDocs(userID, friend, doc);

      friendships.add(friendship);
    }

    return friendships;
  }

  static Future<ImageProvider> getNetworkImage(String downloadUrl) async {
    if (downloadUrl.isEmpty) {
      return Image.asset('assets/account_circle.png').image;
    }
    final ref = FirebaseStorage.instance.refFromURL(downloadUrl);
    final url = await ref.getDownloadURL();

    return NetworkImage(url);
  }
}
