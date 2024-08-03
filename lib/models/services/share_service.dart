import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/objects/picture.dart';
import 'package:befriend/models/objects/profile.dart';
import 'package:befriend/models/services/simple_encryption_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../utilities/constants.dart';
import '../objects/bubble.dart';
import '../objects/friendship.dart';

class ShareService {
  static Uri generatePostShareLink(String pictureId, String profileId) {
    String data = SimpleEncryptionService.encrypt64(
        '$pictureId${Constants.dataSeparator}$profileId');
    data =
        '${SimpleEncryptionService.iv.base64}${Constants.dataSeparator}$data';

    final Uri referralLink = Uri(
      scheme: 'https',
      host: 'befriendesc.com',
      path: Constants.postSharePath,
      queryParameters: {
        Constants.postShareParameter: Uri.encodeComponent(data),
      },
    );

    try {
      FirebaseAnalytics.instance.logShare(
          contentType: 'Referral', itemId: profileId, method: 'Home button');
    } catch (e) {
      debugPrint('(ShareService) Error logging share');
    }

    return referralLink;
  }

  static Future<void> handlePostShare(
      BuildContext context, String pictureId, String profileId) async {
    try {
      final Bubble userBubble = await UserManager.getInstance();
      if (profileId == userBubble.id ||
          userBubble.friendIDs.contains(profileId)) {
        final DocumentSnapshot snapshot =
            await Constants.picturesCollection.doc(pictureId).get();
        final Picture picture = Picture.fromDocument(snapshot);

        if (picture.allowedIDS
                .contains(AuthenticationManager.notArchivedID()) ||
            (picture.allowedIDS.contains(AuthenticationManager.archivedID()) &&
                profileId != userBubble.id) ||
            picture.allowedIDS.contains(userBubble.id)) {
          if (context.mounted) {
            final Bubble user;
            final Friendship? friendship;
            if (profileId == userBubble.id) {
              user = userBubble;
              friendship = null;
            } else {
              friendship =
                  await DataQuery.getFriendship(userBubble.id, profileId);
              user = friendship.friend;
            }

            if (context.mounted) {
              GoRouter.of(context).push(Constants.profileAddress,
                  extra: Profile(
                    user: user,
                    friendship: friendship,
                    currentUser: userBubble,
                    notifyParent: () {},
                  ));
            }
          }
        }
      }
    } catch (e) {
      debugPrint('(ShareService) Error handling post share: $e');
    }
  }
}
