import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class DataManager {
  /// Returns the user data of a certain user.
  /// If the id is given, it returns the user data of the user with the given id.
  /// If the counter is given, it returns the user data of the user with the given counter.
  /// If neither the id nor the counter is given, it returns the user data of the current user.
  static Future<DocumentSnapshot> getData({String? id, int? counter}) async {
    if (id != null) {
      return await _getUserByID(id);
    } else if (counter != null) {
      return await _getUserByCounter(counter);
    } else {
      return await Constants.usersCollection
          .doc(AuthenticationManager.id())
          .get();
    }
  }

  /// Returns the user data of the user with the given id.
  static Future<DocumentSnapshot> _getUserByID(String id) async {
    return await Constants.usersCollection.doc(id).get();
  }

  /// Returns the user data of the user with the given counter.
  static Future<DocumentSnapshot> _getUserByCounter(int counterValue) async {
    final querySnapshot = await Constants.usersCollection
        .where(Constants.counterDoc, isEqualTo: counterValue)
        .get();

    final userDoc = querySnapshot.docs.first;
    return userDoc;
  }

  static Future<ImageProvider> getAvatar(DocumentSnapshot snapshot) async {
    String avatarUrl = getString(snapshot, Constants.avatarDoc);

    return await DataQuery.getNetworkImage(avatarUrl);
  }

  static num getNumber(DocumentSnapshot snapshot, String id) {
    return snapshot.data().toString().contains(id) ? snapshot.get(id) : 0;
  }

  static String getString(DocumentSnapshot snapshot, String id) {
    return snapshot.data().toString().contains(id) ? snapshot.get(id) : '';
  }

  static List<dynamic> getList(DocumentSnapshot snapshot, String id) {
    return snapshot.data().toString().contains(id)
        ? snapshot.get(id)
        : List.empty();
  }
}
