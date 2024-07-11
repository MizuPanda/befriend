import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/objects/bubble.dart';
import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/utilities/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DataQuery {
  static const int _friendsLimit = 12;
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
      debugPrint('(DataQuery): Failed to update document: $e');
      throw Exception('(DataQuery): Failed to update data.');
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

      Bubble friendBubble = Bubble.fromDocsWithoutFriends(bubbleSnap, avatar);
      return Friendship.fromDocs(currentUserID, friendBubble, friendshipSnap);
    } catch (e) {
      debugPrint('(DataQuery): Error fetching friendship data: $e');
      throw Exception('(DataQuery): Failed to fetch friendship data.');
    }
  }

  static Future<List<Friendship>> friendList(
      String userID, List<dynamic> friendIDs) async {
    try {
      final List<Friendship> friendships = [];
      final String mainID = Models.authenticationManager.id();

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
          DocumentSnapshot friendDocs =
              await Models.dataManager.getData(id: friendID);
          ImageProvider avatar = await Models.dataManager.getAvatar(friendDocs);

          friend = Bubble.fromDocsWithoutFriends(friendDocs, avatar);
        }

        friendship = Friendship.fromDocs(userID, friend, doc);

        friendships.add(friendship);
      }
      return friendships;
    } catch (e) {
      debugPrint('(DataQuery): Error retrieving friend list: $e');
      throw Exception('Failed to retrieve friend list.');
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
