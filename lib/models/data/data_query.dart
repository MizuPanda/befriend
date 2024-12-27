import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/objects/bubble.dart';
import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../authentication/authentication.dart';
import 'data_manager.dart';

class DataQuery {
  static FirebaseStorage _storage = FirebaseStorage.instance;

  static set storage(FirebaseStorage value) {
    _storage = value;
  }

  static Future<void> updateDocument(String fieldID, dynamic data,
      {String? userId}) async {
    try {
      await Constants.usersCollection
          .doc(userId ?? AuthenticationManager.id())
          .update(<String, dynamic>{fieldID: data});
    } catch (e) {
      debugPrint('(DataQuery) Failed to update document: $e');
      throw Exception('(DataQuery) Failed to update data.');
    }
  }

  static Future<Friendship> getFriendshipFromBubble(Bubble friend) async {
    try {
      final List<String> ids = [AuthenticationManager.id(), friend.id];
      ids.sort();
      final String friendshipID = ids.first + ids.last;

      final DocumentSnapshot friendshipSnap =
          await Constants.friendshipsCollection.doc(friendshipID).get();

      return Friendship.fromDocs(
          AuthenticationManager.id(), friend, friendshipSnap);
    } catch (e) {
      debugPrint('(DataQuery) Error fetching friendship data: $e');
      throw Exception('(DataQuery) Failed to fetch friendship data.');
    }
  }

  static Future<Friendship> getFriendship(
      String currentUserID, String otherUserID) async {
    try {
      List<String> ids = [currentUserID, otherUserID];
      ids.sort();
      String friendshipID = ids.first + ids.last;

      DocumentSnapshot friendshipSnap =
          await Constants.friendshipsCollection.doc(friendshipID).get();
      DocumentSnapshot bubbleSnap = await DataManager.getData(id: otherUserID);
      ImageProvider avatar = await DataManager.getAvatar(bubbleSnap);

      Bubble friendBubble = Bubble.fromDocs(bubbleSnap, avatar);
      return Friendship.fromDocs(currentUserID, friendBubble, friendshipSnap);
    } catch (e) {
      debugPrint('(DataQuery) Error fetching friendship data: $e');
      throw Exception('(DataQuery) Failed to fetch friendship data.');
    }
  }

  static Future<ImageProvider> getNetworkImage(String downloadUrl) async {
    try {
      if (downloadUrl.isEmpty) {
        return Image.asset(Constants.defaultPictureAddress).image;
      }
      final ref = _storage.refFromURL(downloadUrl);
      final url = await ref.getDownloadURL();

      return NetworkImage(url);
    } catch (e) {
      debugPrint('(DataQuery): Error loading network image: $e');
      return Image.asset(Constants.defaultPictureAddress).image;
    }
  }

  static Future<String> getUsername(String id) async {
    if (id == AuthenticationManager.id()) {
      final Bubble player = await UserManager.getInstance();

      return player.username;
    }

    final DocumentSnapshot snapshot = await DataManager.getData(id: id);

    return DataManager.getString(snapshot, Constants.usernameDoc);
  }
}
