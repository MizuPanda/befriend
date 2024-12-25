import 'package:flutter/cupertino.dart';

import 'bubble.dart';

class SearchHistory {
  final DateTime _timestamp;
  final Bubble _bubble;

  SearchHistory(this._timestamp, this._bubble);

  DateTime get timestamp => _timestamp;

  ImageProvider get avatar => _bubble.avatar;

  String get username => _bubble.username;

  Bubble get bubble => _bubble;
}
