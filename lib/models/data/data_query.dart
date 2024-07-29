import 'package:befriend/models/objects/bubble.dart';
import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/utilities/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DataQuery {
  static FirebaseStorage _storage = FirebaseStorage.instance;

  static set storage(FirebaseStorage value) {
    _storage = value;
  }

  static Future<void> updateDocument(String fieldID, dynamic data,
      {String? userId}) async {
    try {
      await Constants.usersCollection
          .doc(userId ?? Models.authenticationManager.id())
          .update(<String, dynamic>{fieldID: data});
    } catch (e) {
      debugPrint('(DataQuery) Failed to update document: $e');
      throw Exception('(DataQuery) Failed to update data.');
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
      DocumentSnapshot bubbleSnap =
          await Models.dataManager.getData(id: otherUserID);
      ImageProvider avatar = await Models.dataManager.getAvatar(bubbleSnap);

      Bubble friendBubble = Bubble.fromDocs(bubbleSnap, avatar);
      return Friendship.fromDocs(currentUserID, friendBubble, friendshipSnap);
    } catch (e) {
      debugPrint('(DataQuery): Error fetching friendship data: $e');
      throw Exception('(DataQuery): Failed to fetch friendship data.');
    }
  }

  Future<ImageProvider> getNetworkImage(String downloadUrl) async {
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

  DataQuery.static();
}
