import 'package:cloud_firestore/cloud_firestore.dart';

class Constants {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String nameDoc = 'name';
  static const String usernameDoc = 'username';
  static const String avatarDoc = 'avatar';
  static const String counterDoc = 'counter';
  static const String friendsDoc = 'friends';

  static const String progressDoc = 'progress';
  static const String levelDoc = 'level';
  static String newPics(int userIndex) {
    return 'newPics$userIndex';
  }

  static final CollectionReference friendshipsCollection = _firestore.collection('friendships');
  static final CollectionReference usersCollection = _firestore.collection('users');
}