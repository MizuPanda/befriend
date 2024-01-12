import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/data/data_query.dart';
import '../models/data/picture_manager.dart';
import '../models/objects/bubble.dart';
import '../models/objects/host.dart';
import '../utilities/constants.dart';

class SessionProvider extends ChangeNotifier {
  Host host;
  final Map<String, Bubble> idToBubbleMap;
  final List<String> ids;

  Future<void> initPicture() async {
    if(host.main()) {
      await _pictureProcess();
    }
  }

  Future<void> _pictureProcess() async {
    String? imageUrl;
    await PictureManager.cameraPicture((String? url) {
      imageUrl = url;
    });
    if(imageUrl != null) {
      List<String> pictureUrl = ['${Constants.pictureMarker}${imageUrl!}'];
      await DataQuery.updateDocument(Constants.hostingDoc, pictureUrl);
    }
  }

  SessionProvider._({required this.host, required this.idToBubbleMap, required this.ids});

  factory SessionProvider.builder(Host host){
    Map<String, Bubble> idToBubbleMap = {
      for (var bubble in host.joiners) bubble.id : bubble
    };
    List<String> ids = idToBubbleMap.keys.toList();

    return SessionProvider._(host: host, idToBubbleMap: idToBubbleMap, ids: ids);
  }

  Bubble? bubble(String id) {
    return idToBubbleMap[id];
  }

  double sliderValue(QueryDocumentSnapshot userDocument) {
    return (userDocument[Constants.sliderDoc] as num).toDouble();
  }

  Image image() {
    return Image(
        image: NetworkImage(
          host.imageUrl!,
        ));
  }

  String hostUsername() {
    return host.host.username;
  }

  bool imageNull() {
    return host.imageUrl == null;
  }

  bool isUser(String id) {
    return host.user.id == id;
  }

  int length() {
    return host.joiners.length;
  }

}