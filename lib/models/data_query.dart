import 'package:befriend/models/bubble.dart';
import 'package:befriend/models/data_manager.dart';
import 'package:befriend/models/friend_manager.dart';
import 'package:befriend/models/friendship.dart';
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

  static Future<List<Friendship>> friendList(String userID, List<dynamic> friendIDs) async {
    List<Friendship> friendships = [];
    for (String friendID in friendIDs) {
      DocumentSnapshot friendDocs = await DataManager.getData(id: friendID);
      Bubble friend = Bubble.fromMapWithoutFriends(friendDocs);


      DocumentSnapshot friendshipDocs = await FriendManager.getData(userID, friend.id);
      Friendship friendship = Friendship.fromDocs(userID, friend, friendshipDocs);
      friendships.add(friendship);
    }

    return friendships;
  }

  static Future<ImageProvider> getAvatarImage(String downloadUrl) async {
      final ref = FirebaseStorage.instance.refFromURL(downloadUrl);
      final url = await ref.getDownloadURL();

      return NetworkImage(url);
  }

}