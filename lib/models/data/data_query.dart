import 'package:befriend/models/objects/bubble.dart';
import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/data/friend_manager.dart';
import 'package:befriend/models/objects/friendship.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

class DataQuery {
  static final FirebaseFirestore _fb = FirebaseFirestore.instance;

  static Future<void> updateAvatar(String downloadUrl) async {
    _fb
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .update(<String, dynamic>{"avatar": downloadUrl});
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

  static Future<ImageProvider> getAvatarImage(String downloadUrl) async {
    //HERE IS WHERE I SHOULD MANAGE AVATAR URL = NULL

    final ref = FirebaseStorage.instance.refFromURL(downloadUrl);
    final url = await ref.getDownloadURL();

    return NetworkImage(url);
  }
}
