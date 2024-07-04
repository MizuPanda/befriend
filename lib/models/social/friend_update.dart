import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class FriendUpdate {
  static Future<void> addFriend(String friendID,
      {required String mainUserId}) async {
    try {
      await Constants.usersCollection.doc(mainUserId).update({
        Constants.friendsDoc: FieldValue.arrayUnion([friendID]),
      });
      debugPrint('(FriendUpdate): Successfully added friend $friendID');
    } catch (e) {
      debugPrint('(FriendUpdate): Error adding friend $friendID: $e');
      // Optionally, handle error for user feedback
    }
  }
}
