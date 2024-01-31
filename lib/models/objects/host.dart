import 'dart:io';

import 'package:befriend/utilities/constants.dart';

import 'bubble.dart';
import 'friendship_progress.dart';

class Host {
  Bubble host;
  List<Bubble> joiners;
  Bubble user;
  String? imageUrl;
  String? _imagePath;
  final List<File> _temporaryFiles = [];

  Map<String, List<FriendshipProgress>> friendshipsMap = {};


  Host({required this.host, required this.joiners, required this.user});

  bool main() {
    return host == user;
  }

  File tempFile() {
    return File(_imagePath!);
  }

  void addCacheFile() {
    _temporaryFiles.add(File(_imagePath!));
  }

  void clearTemporaryFiles() {
    for (File file in _temporaryFiles) {
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
    _temporaryFiles.clear();
  }

  set imagePath(String? value) {
    _imagePath = value;
  }

  bool pathNull () {
    return _imagePath == null;
  }

  Future<void> updateDocument(String docId, dynamic data) async {
    await Constants.usersCollection.doc(host.id).update({docId: data});
  }
}
