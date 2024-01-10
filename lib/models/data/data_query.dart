import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/objects/bubble.dart';
import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/data/friend_manager.dart';
import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class DataQuery {
  static Future<void> updateDocument(String docId, dynamic data) async {
    await Constants.usersCollection
        .doc(AuthenticationManager.id())
        .update(<String, dynamic>{docId: data});
  }

  static Future<void> updateAvatar(String downloadUrl) async {
    await updateDocument(Constants.avatarDoc, downloadUrl);
  }

  static Future<List<Friendship>> friendList(
      String userID, List<dynamic> friendIDs) async {
    List<Friendship> friendships = [];
    for (String friendID in friendIDs) {
      DocumentSnapshot friendDocs = await DataManager.getData(id: friendID);
      ImageProvider avatar = await DataManager.getAvatar(friendDocs);

      Bubble friend = Bubble.fromMapWithoutFriends(friendDocs, avatar);

      DocumentSnapshot friendshipDocs =
          await FriendManager.getData(userID, friend.id);
      Friendship friendship =
          Friendship.fromDocs(userID, friend, friendshipDocs);
      friendships.add(friendship);
    }

    return friendships;
  }

  static Future<ImageProvider> getNetworkImage(String downloadUrl) async {
    final ref = FirebaseStorage.instance.refFromURL(downloadUrl);
    final url = await ref.getDownloadURL();

    return NetworkImage(url);
  }
}
