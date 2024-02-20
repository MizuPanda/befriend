import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utilities/constants.dart';
import '../data/data_manager.dart';
import '../objects/friendship_progress.dart';

class FriendshipUpdate {
  static Future<void> addProgress(String userID1, String userID2,
      DocumentSnapshot friendshipDoc, DateTime timestamp,
      {required double exp}) async {
    // Update existing friendship
    double progress =
        DataManager.getNumber(friendshipDoc, Constants.progressDoc).toDouble();
    progress += exp;

    if (progress >= 1) {
      progress -= 1;

      await Constants.friendshipsCollection.doc(friendshipDoc.id).update({
        Constants.progressDoc: progress,
        Constants.levelDoc: FieldValue.increment(1),
        Constants.timestampDoc: timestamp,
      });

      await Constants.usersCollection
          .doc(userID1)
          .update({Constants.powerDoc: FieldValue.increment(1)});
      await Constants.usersCollection
          .doc(userID2)
          .update({Constants.powerDoc: FieldValue.increment(1)});
    } else {
      await Constants.friendshipsCollection.doc(friendshipDoc.id).update({
        Constants.progressDoc: progress,
        Constants.timestampDoc: timestamp,
      });
    }
  }

  static Future<void> createFriendship(
      {required String userID1,
      required String userID2,
      required String username1,
      required String username2,
      required String friendshipDocId,
      required DateTime timestamp}) async {
    FriendshipProgress newFriendship = FriendshipProgress.newFriendship(
        userID1, userID2, username1, username2, 1, 0.05, timestamp);
    await Constants.friendshipsCollection
        .doc(friendshipDocId)
        .set(newFriendship.toMap());
  }
}
