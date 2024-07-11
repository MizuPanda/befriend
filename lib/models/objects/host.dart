import 'dart:io';

import 'package:befriend/models/qr/privacy.dart';
import 'package:flutter/cupertino.dart';

import 'bubble.dart';
import 'friendship_progress.dart';

class Host {
  Bubble host;
  List<Bubble> joiners;
  Bubble user;
  String? imageUrl;
  String? _imagePath;
  final List<File> _temporaryFiles = [];
  final Privacy _privacy = Privacy();

  Map<String, List<FriendshipProgress>> friendshipsMap = {};

  Host({required this.host, required this.joiners, required this.user});

  bool isPublic() {
    return _privacy.isPublic;
  }

  bool isPrivate() {
    return _privacy.isPrivate;
  }

  Set<String> friendsAllowed() {
    return _privacy.friendsAllowed;
  }

  void calculateAllowedUsers(
      Map<String, double> sliderValuesMap, Bubble? Function(String) bubble) {
    _privacy.calculateAllowedUsers(this, sliderValuesMap, bubble);
  }

  void showFriendList(BuildContext context, Map<String, double> sliderValuesMap,
      Bubble? Function(String) bubble) {
    _privacy.showFriendList(context, this, sliderValuesMap, bubble);
  }

  void setCriticalPoints() {
    _privacy.setCriticalPoints(this);
  }

  int pointsLength() {
    return _privacy.criticalPoints.length;
  }

  Set<double> criticalPoints() {
    return _privacy.criticalPoints;
  }

  double getPoint(int selectedIndex) {
    return _privacy.criticalPoints.elementAt(selectedIndex);
  }

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

  bool pathNull() {
    return _imagePath == null;
  }
}
