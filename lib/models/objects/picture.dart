import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/data/data_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utilities/constants.dart';

class Picture {
  final String id;
  final String hostId;
  final String fileUrl;
  final String pictureTaker;
  final DateTime timestamp;
  final Map<String, dynamic> metadata; //String size, String extension
  final String caption;
  final List<dynamic> allowedIDS;
  final List<dynamic> sessionUsers;
  final bool isPublic;
  List<dynamic> likes;
  List<dynamic> firstLikes;

  Picture._({
    required this.id,
    required this.hostId,
    required this.fileUrl,
    required this.pictureTaker,
    required this.timestamp,
    required this.metadata,
    required this.caption,
    required this.allowedIDS,
    required this.sessionUsers,
    required this.likes,
    required this.firstLikes,
    required this.isPublic,
  });

  static final pictureAd = Picture._(
    id: 'ad',
    hostId: 'google',
    fileUrl: '',
    pictureTaker: 'google',
    timestamp: DateTime(0),
    metadata: {},
    caption: '',
    allowedIDS: [],
    sessionUsers: [],
    likes: [],
    firstLikes: [],
    isPublic: false,
  );

  factory Picture.fromDocument(DocumentSnapshot docs, String hostUsername) {
    String url = DataManager.getString(docs, Constants.urlDoc);

    return Picture._(
        id: docs.id,
        hostId: DataManager.getString(docs, Constants.hostIdDoc),
        fileUrl: url,
        pictureTaker: hostUsername,
        timestamp: DataManager.getDateTime(docs, Constants.timestampDoc),
        metadata: DataManager.getMap(docs, Constants.metadataDoc),
        caption: DataManager.getString(docs, Constants.captionDoc),
        allowedIDS: DataManager.getList(docs, Constants.allowedUsersDoc),
        sessionUsers: DataManager.getList(docs, Constants.sessionUsersDoc),
        likes: DataManager.getList(docs, Constants.likesDoc),
        firstLikes: DataManager.getList(docs, Constants.firstLikesDoc),
        isPublic: DataManager.getBoolean(docs, Constants.publicDoc));
  }

  bool hasUserArchived() {
    return allowedIDS.contains(AuthenticationManager.archivedID());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Picture &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          pictureTaker == other.pictureTaker &&
          timestamp == other.timestamp;

  @override
  int get hashCode => id.hashCode ^ pictureTaker.hashCode ^ timestamp.hashCode;
}
