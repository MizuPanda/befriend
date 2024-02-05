import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/data/friendship_accumulator.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/objects/bubble.dart';
import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/data/friend_manager.dart';
import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DataQuery {
  static Future<void> updateDocument(String docId, dynamic data) async {
    await Constants.usersCollection
        .doc(AuthenticationManager.id())
        .update(<String, dynamic>{docId: data});
  }

  static Future<List<Friendship>> friendList(
      String userID, List<dynamic> friendIDs) async {
    final FriendshipAccumulator accumulator = FriendshipAccumulator();
    final List<Friendship> friendships = [];
    final String mainID = AuthenticationManager.id();

    for (String friendID in friendIDs) {
      Bubble friend;
      Friendship friendship;

      if (mainID != userID && friendID == mainID) {
        friend = await UserManager.getInstance();
      } else {
        DocumentSnapshot friendDocs = await DataManager.getData(id: friendID);
        ImageProvider avatar = await DataManager.getAvatar(friendDocs);

        friend = Bubble.fromMapWithoutFriends(friendDocs, avatar);
      }

      Friendship? f = accumulator.containsFriendship(userID, friendID, friend);

      if (f != null) {
        friendship = f;
      } else {
        DocumentSnapshot friendshipDocs =
        await FriendManager.getData(userID, friend.id);

        friendship = Friendship.fromDocs(friend, friendshipDocs);
      }

      friendships.add(friendship);
      accumulator.addFriendship(friendship);
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
