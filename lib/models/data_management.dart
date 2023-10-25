import 'package:cloud_firestore/cloud_firestore.dart';

class DataManagement {
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
