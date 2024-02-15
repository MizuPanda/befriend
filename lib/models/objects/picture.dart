import 'dart:io';
import 'dart:math';

import 'package:befriend/models/data/data_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../utilities/constants.dart';

class Picture extends PictureData {
  ImageProvider image;

  // Just for testing
  factory Picture.fromData(PictureData data) {
    String url = data.fileUrl;
    ImageProvider img = NetworkImage(url);

    return Picture._(
        image: img,
        id: data.id,
        fileUrl: data.fileUrl,
        pictureTaker: data.pictureTaker,
        timestamp: data.timestamp,
        metadata: data.metadata,
        public: data.public,
        caption: data.caption,
        allowedIDS: data.allowedIDS,
        sessionUsernames: data.sessionUsernames);
  }

  Picture._(
      {required this.image,
      required super.id,
      required super.fileUrl,
      required super.pictureTaker,
      required super.timestamp,
      required super.metadata,
      required super.public,
      required super.caption,
      required super.allowedIDS,
      required super.sessionUsernames});

  factory Picture.fromDocument(
    DocumentSnapshot docs,
  ) {
    String url = DataManager.getString(docs, Constants.urlDoc);
    ImageProvider img = NetworkImage(url);

    return Picture._(
        image: img,
        id: docs.id,
        fileUrl: url,
        pictureTaker: DataManager.getString(docs, Constants.pictureTakerDoc),
        timestamp: DataManager.getDateTime(docs, Constants.timestampDoc),
        metadata: DataManager.getMap(docs, Constants.metadataDoc),
        public: DataManager.getBoolean(docs, Constants.publicDoc),
        caption: DataManager.getString(docs, Constants.captionDoc),
        allowedIDS: DataManager.getList(docs, Constants.allowedUsersDoc),
        sessionUsernames: DataManager.getList(docs, Constants.sessionUsersDoc));
  }
}

class PictureData {
  String id;
  String fileUrl;
  String pictureTaker;
  DateTime timestamp;
  Map<String, dynamic> metadata; //String size, String extension
  bool public;
  String caption;
  List<dynamic> allowedIDS;
  List<dynamic> sessionUsernames;

  PictureData(
      {required this.id,
      required this.fileUrl,
      required this.pictureTaker,
      required this.timestamp,
      required this.metadata,
      required this.public,
      required this.caption,
      required this.allowedIDS,
      required this.sessionUsernames});

  factory PictureData.fromDocument(
    DocumentSnapshot docs,
  ) {
    return PictureData(
        id: docs.id,
        pictureTaker: DataManager.getString(docs, Constants.pictureTakerDoc),
        fileUrl: DataManager.getString(docs, Constants.urlDoc),
        timestamp: DataManager.getDateTime(docs, Constants.timestampDoc),
        metadata: DataManager.getMap(docs, Constants.metadataDoc),
        public: DataManager.getBoolean(docs, Constants.publicDoc),
        caption: DataManager.getString(docs, Constants.captionDoc),
        allowedIDS: DataManager.getList(docs, Constants.allowedUsersDoc),
        sessionUsernames: DataManager.getList(docs, Constants.sessionUsersDoc));
  }

  factory PictureData.newPicture(
    String fileUrl,
    String pictureTaker,
    DateTime timestamp,
    File file,
    bool isPublic,
    String caption,
    List<dynamic> allowedIDS,
    List<dynamic> sessionUsernames,
  ) {
    String uuid = const Uuid().v4().toString();
    Map<String, String> metadata = {
      'size': _formatBytes(file.lengthSync(), 0),
      'extension': path.extension(file.path),
    };
    return PictureData(
        id: uuid,
        fileUrl: fileUrl,
        pictureTaker: pictureTaker,
        timestamp: timestamp,
        metadata: metadata,
        public: isPublic,
        caption: caption,
        allowedIDS: allowedIDS,
        sessionUsernames: sessionUsernames);
  }

  Map<String, dynamic> toMap() {
    return {
      Constants.urlDoc: fileUrl,
      Constants.pictureTakerDoc: pictureTaker,
      Constants.timestampDoc: timestamp,
      Constants.metadataDoc: metadata,
      Constants.publicDoc: public,
      Constants.captionDoc: caption,
      Constants.allowedUsersDoc: allowedIDS,
      Constants.sessionUsersDoc: sessionUsernames
    };
  }

  static String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
