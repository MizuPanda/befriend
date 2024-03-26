import 'dart:io';
import 'dart:math';

import 'package:befriend/models/data/data_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

import '../../utilities/constants.dart';

class Picture {
  final String id;
  final String hostId;
  final String fileUrl;
  final String pictureTaker;
  final DateTime timestamp;
  final Map<String, dynamic> metadata; //String size, String extension
  final bool public;
  final String caption;
  final List<dynamic> allowedIDS;
  final Map<String, dynamic> sessionUsers;
  List<dynamic> likes;
  List<dynamic> firstLikes;
  final bool archived;

  Picture._({
    required this.id,
    required this.hostId,
    required this.fileUrl,
    required this.pictureTaker,
    required this.timestamp,
    required this.metadata,
    required this.public,
    required this.caption,
    required this.allowedIDS,
    required this.sessionUsers,
    required this.likes,
    required this.firstLikes,
    required this.archived,
  });

  static final pictureAd = Picture._(
      id: 'ad',
      hostId: 'google',
      fileUrl: '',
      pictureTaker: 'google',
      timestamp: DateTime(0),
      metadata: {},
      public: true,
      caption: '',
      allowedIDS: [],
      sessionUsers: {},
      likes: [],
      firstLikes: [],
      archived: false);

  factory Picture.newPicture(
    String fileUrl,
    String hostId,
    String pictureTaker,
    DateTime timestamp,
    File file,
    bool isPublic,
    String caption,
    List<dynamic> allowedIDS,
    Map<String, String> sessionUsers,
  ) {
    Map<String, String> metadata = {
      'size': _formatBytes(file.lengthSync(), 0),
      'extension': path.extension(file.path),
    };
    return Picture._(
        id: '',
        hostId: hostId,
        fileUrl: fileUrl,
        pictureTaker: pictureTaker,
        timestamp: timestamp,
        metadata: metadata,
        public: isPublic,
        caption: caption,
        allowedIDS: allowedIDS,
        sessionUsers: sessionUsers,
        likes: List.empty(),
        firstLikes: List.empty(),
        archived: false);
  }

  factory Picture.fromDocument(
    DocumentSnapshot docs,
  ) {
    String url = DataManager.getString(docs, Constants.urlDoc);

    return Picture._(
        id: docs.id,
        hostId: DataManager.getString(docs, Constants.hostId),
        fileUrl: url,
        pictureTaker: DataManager.getString(docs, Constants.pictureTakerDoc),
        timestamp: DataManager.getDateTime(docs, Constants.timestampDoc),
        metadata: DataManager.getMap(docs, Constants.metadataDoc),
        public: DataManager.getBoolean(docs, Constants.publicDoc),
        caption: DataManager.getString(docs, Constants.captionDoc),
        allowedIDS: DataManager.getList(docs, Constants.allowedUsersDoc),
        sessionUsers: DataManager.getMap(docs, Constants.sessionUsersDoc),
        likes: DataManager.getList(docs, Constants.likesDoc),
        firstLikes: DataManager.getList(docs, Constants.firstLikesDoc),
        archived: DataManager.getBoolean(docs, Constants.archived));
  }

  Map<String, dynamic> toMap() {
    return {
      Constants.hostId: hostId,
      Constants.urlDoc: fileUrl,
      Constants.pictureTakerDoc: pictureTaker,
      Constants.timestampDoc: timestamp,
      Constants.metadataDoc: metadata,
      Constants.publicDoc: public,
      Constants.captionDoc: caption,
      Constants.allowedUsersDoc: allowedIDS,
      Constants.sessionUsersDoc: sessionUsers,
      Constants.likesDoc: likes,
      Constants.firstLikesDoc: firstLikes,
      Constants.archived: archived,
    };
  }

  static String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
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
