import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/qr/host_listening.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    if (host.main()) {
      await _pictureProcess();
    }
  }

  Future<void> _pictureProcess() async {
    String? imageUrl;
    await PictureManager.cameraPicture((String? url) {
      imageUrl = url;
    });
    if (imageUrl != null) {
      List<String> pictureUrl = ['${Constants.pictureMarker}${imageUrl!}'];
      await DataQuery.updateDocument(Constants.hostingDoc, pictureUrl);
    }
  }

  Future<String> processSnapshot(
      QuerySnapshot snapshot, BuildContext context) async {
    await handleCancelled(snapshot, context);

    return 'Completed';
  }

  Future<void> handlePicture(QuerySnapshot snapshot) async {
    DocumentSnapshot? hostDoc;
    for (DocumentChange change in snapshot.docChanges) {
      if (change.doc.id == host.host.id) {
        hostDoc = change.doc;
        break;
      }
    }
    if (hostDoc != null) {
      List<dynamic> connectedIds =
          DataManager.getList(hostDoc, Constants.hostingDoc);

      if (HostListening.hasPictureBeenTaken(connectedIds)) {}
    }
  }

  Future<void> handleCancelled(
      QuerySnapshot snapshot, BuildContext context) async {
    bool isCancelled = false;
    String id = '';
    List<dynamic> connectedIds = [];

    for (DocumentChange doc in snapshot.docChanges) {
      connectedIds = DataManager.getList(doc.doc, Constants.hostingDoc);

      if (connectedIds.contains(Constants.cancelledState)) {
        id = doc.doc.id;
        isCancelled = true;
        debugPrint('(SessionProvider): $id Cancelled');

        break;
      }
    }
    if (isCancelled) {
      debugPrint('(SessionProvider): Was Cancelled');
      connectedIds.remove(Constants.cancelledState);
      await Constants.usersCollection
          .doc(id)
          .update({Constants.hostingDoc: connectedIds});

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        notifyListeners();
      });

      if (context.mounted) {
        GoRouter.of(context).pop();
      }
    }
  }

  Future<void> cancelLobby(BuildContext context) async {
    // UPDATE HOSTING DOCUMENT WITH A LIST OF (JOINERS LENGTH) CONSTANT.CANCEL
    List<String> cancels = [];
    for (int i = 0; i < host.joiners.length - 1; i++) {
      cancels.add(Constants.cancelledState);
    }

    await DataQuery.updateDocument(Constants.hostingDoc, cancels);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });

    if (context.mounted) {
      GoRouter.of(context).pop();
    }
  }

  SessionProvider._(
      {required this.host, required this.idToBubbleMap, required this.ids});

  factory SessionProvider.builder(Host host) {
    Map<String, Bubble> idToBubbleMap = {
      for (var bubble in host.joiners) bubble.id: bubble
    };
    List<String> ids = idToBubbleMap.keys.toList();

    return SessionProvider._(
        host: host, idToBubbleMap: idToBubbleMap, ids: ids);
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
