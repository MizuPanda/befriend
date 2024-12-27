import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';

class PostService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  static Future<void> sendPostNotification(List<String> userIds,
      String postCreatorName, String hostId, BuildContext context) async {
    final String languageCode = Localizations.localeOf(context).languageCode;

    await _sendNotification('sendNewPostNotification', {
      'userIds': userIds,
      'postCreatorName': postCreatorName,
      'hostId': hostId,
      'languageCode': languageCode
    });
  }

  static Future<void> sendPostLikeNotification(
      String likerUsername, List<dynamic> sessionUsers) async {
    await _sendNotification('sendPostLikeNotification', {
      'likerUsername': likerUsername,
      'sessionUsers': sessionUsers,
    });
  }

  static Future<void> _sendNotification(
      String functionName, Map<String, dynamic> data) async {
    try {
      HttpsCallable callable = _functions.httpsCallable(functionName);
      final results = await callable.call(data);
      debugPrint('(PostService) Cloud function executed, results: $results');
    } catch (e) {
      debugPrint('(PostService) Error calling cloud function= $e');
    }
  }
}
