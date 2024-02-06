import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendUpdate {
  static Future<void> addFriend(String friendID,
      {required String mainUserId}) async {
    await Constants.usersCollection.doc(mainUserId).update({
      Constants.friendsDoc: FieldValue.arrayUnion([friendID]),
      Constants.powerDoc: FieldValue.increment(1),
    });
  }
}
