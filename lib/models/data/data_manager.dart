import 'package:befriend/utilities/constants.dart';
import 'package:befriend/utilities/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class DataManager {
  DataManager.static();

  /// Returns the user data of a certain user.
  /// If the id is given, it returns the user data of the user with the given id.
  /// If neither the id nor the counter is given, it returns the user data of the current user.
  Future<DocumentSnapshot> getData({String? id}) async {
    try {
      return await Constants.usersCollection
          .doc(id ?? Models.authenticationManager.id())
          .get();
    } catch (e) {
      debugPrint('(DataManager): Error fetching data: $e');
      throw Exception(
          '(DataManager): Failed to fetch user data'); // Or handle more gracefully depending on your app's needs
    }
  }

  Future<ImageProvider> getAvatar(DocumentSnapshot snapshot) async {
    try {
      String avatarUrl = getString(snapshot, Constants.avatarDoc);
      return await Models.dataQuery.getNetworkImage(avatarUrl);
    } catch (e) {
      debugPrint('(DataManager): Error loading avatar image: $e');
      return Image.asset('assets/images/account_circle.png').image;
      // Fallback to a default image in case of an error
    }
  }

  static num getNumber(DocumentSnapshot snapshot, String id) {
    return snapshot.data().toString().contains(id) ? snapshot.get(id) : 0;
  }

  static Map<String, dynamic> getMap(DocumentSnapshot snapshot, String id) {
    return snapshot.data().toString().contains(id) ? snapshot.get(id) : {};
  }

  static Map<String, DateTime> getDateTimeMap(
      DocumentSnapshot snapshot, String id) {
    return DataManager.getMap(snapshot, Constants.lastSeenUsersMapDoc)
        .map((key, value) => MapEntry(key, (value as Timestamp).toDate()));
  }

  static bool getBoolean(DocumentSnapshot snapshot, String id) {
    return snapshot.data().toString().contains(id) ? snapshot.get(id) : false;
  }

  static String getString(DocumentSnapshot snapshot, String id) {
    return snapshot.data().toString().contains(id) ? snapshot.get(id) : '';
  }

  static List<dynamic> getList(DocumentSnapshot snapshot, String id) {
    return snapshot.data().toString().contains(id)
        ? snapshot.get(id)
        : List.empty();
  }

  static DateTime getDateTime(DocumentSnapshot snapshot, String id) {
    try {
      if (snapshot.data().toString().contains(id)) {
        Timestamp timestamp = snapshot.get(id);
        return timestamp.toDate();
      }
      return DateTime.now();
    } catch (e) {
      debugPrint('(DataManager): Error converting timestamp: $e');
      return DateTime.now();
    }
  }
}
