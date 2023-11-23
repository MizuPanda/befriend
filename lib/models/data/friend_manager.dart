import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendManager {
  static Future<DocumentSnapshot> getData(
      String userID, String friendID) async {
    List<String> ids = [userID, friendID];
    ids.sort();
    String docID = ids.first + ids.last;
    return await Constants.friendshipsCollection.doc(docID).get();
  }
}
