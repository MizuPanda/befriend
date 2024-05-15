import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';

class PostService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  static void sendPostNotification(
      List<dynamic> userIds, String postCreatorName, String hostId) async {
    try {
      HttpsCallable callable =
          _functions.httpsCallable('sendNewPostNotification');
      final results = await callable.call({
        'userIds': userIds,
        'postCreatorName': postCreatorName,
        'hostId': hostId,
      });
      debugPrint('(PostService): Cloud function executed, results: $results');
    } catch (e) {
      debugPrint('(PostService): Error calling cloud function= $e');
    }
  }

  static void sendPostLikeNotification(
      String likerUsername, String ownerId) async {
    try {
      HttpsCallable callable =
          _functions.httpsCallable('sendPostLikeNotification');
      final results = await callable.call({
        'likerUsername': likerUsername,
        'ownerId': ownerId,
      });
      debugPrint('(PostService): Cloud function executed, results: $results');
    } catch (e) {
      debugPrint('(PostService): Error calling cloud function= $e');
    }
  }
}
