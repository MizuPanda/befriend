import 'dart:math';

import 'package:befriend/models/data/data_manager.dart';
import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/models/objects/friendship_progress.dart';
import 'package:befriend/models/services/simple_encryption_service.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/views/dialogs/services/invalid_invitation_dialog.dart';
import 'package:befriend/views/dialogs/services/invitation_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../authentication/authentication.dart';
import '../objects/bubble.dart';

class ReferralService {
  static Uri generateReferralLink() {
    String token = _generateUniqueToken();

    // Store the token in the database with the referrer ID
    _storeToken(
      token,
    );

    String data = SimpleEncryptionService.encrypt64(
        '${AuthenticationManager.id()}${Constants.dataSeparator}$token');
    data =
        '${SimpleEncryptionService.iv.base64}${Constants.dataSeparator}$data';

    final Uri referralLink = Uri(
      scheme: 'https',
      host: 'befriendesc.com',
      path: Constants.referralPath,
      queryParameters: {
        Constants.referrerDataParameter: Uri.encodeComponent(data),
      },
    );

    return referralLink;
  }

  static String _generateUniqueToken() {
    // Generate a random string as a unique token
    const length = 20;
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  static Future<void> _storeToken(
    String token,
  ) async {
    // Store the token in the database with the associated user ID
    DateTime timestamp = DateTime.timestamp();
    DocumentSnapshot snapshot =
        await DataManager.getData(id: AuthenticationManager.id());
    Map<String, dynamic> inviteTokens =
        DataManager.getMap(snapshot, Constants.inviteTokensDoc);

    inviteTokens.removeWhere((key, value) =>
        timestamp
            .difference((value as Timestamp).toDate())
            .compareTo(const Duration(days: 1)) >=
        0);
    inviteTokens[token] = timestamp;
    await DataQuery.updateDocument(Constants.inviteTokensDoc, inviteTokens);
  }

  static Future<void> validateToken(
      String referrerId, String token, BuildContext context) async {
    try {
      final Bubble userBubble = await UserManager.getInstance();
      String userId = AuthenticationManager.id();

      if (referrerId != userId && !userBubble.friendIDs.contains(referrerId)) {
        final DocumentSnapshot snapshot =
            await DataManager.getData(id: referrerId);
        final Map<String, dynamic> inviteTokens =
            DataManager.getMap(snapshot, Constants.inviteTokensDoc);
        final List<dynamic> friendsId =
            DataManager.getList(snapshot, Constants.friendsDoc);

        if (inviteTokens.containsKey(token) && !friendsId.contains(userId)) {
          // If the token is valid, prompt the user to accept the invitation
          final ImageProvider avatar = await DataManager.getAvatar(snapshot);
          final Bubble referrer = Bubble.fromDocs(snapshot, avatar);

          if (context.mounted) {
            InvitationDialog.dialog(
                context, referrer, userBubble, token, inviteTokens);
          }
        } else {
          // Show error message if token is invalid
          if (context.mounted) {
            InvalidInvitationDialog.dialog(context);
          }
        }
      }
    } catch (e) {
      debugPrint('(ReferralService) Error validating token: $e');
    }
  }

  static Future<void> addFriend(
      BuildContext context,
      Bubble referrer,
      Bubble userBubble,
      String token,
      Map<String, dynamic> inviteTokens) async {
    try {
      final List<String> ids = [userBubble.id, referrer.id];
      ids.sort();
      final String friendshipId = ids.join();

      final String username1;
      final String username2;

      if (userBubble.id == ids.first) {
        username1 = userBubble.username;
        username2 = referrer.username;
      } else {
        username1 = referrer.username;
        username2 = userBubble.username;
      }

      final FriendshipProgress friendshipProgress =
          FriendshipProgress.newFriendship(ids.first, ids.last, username1,
              username2, 0, 0, DateTime.timestamp());

      // Update database to add the friendship doc
      await Constants.friendshipsCollection
          .doc(friendshipId)
          .set(friendshipProgress.toMap());

      inviteTokens.remove(token);

      // Update database to add friend
      //await Models.dataManager.addFriend(userId, referrerId);
      await DataQuery.updateDocument(
          Constants.friendsDoc, FieldValue.arrayUnion([referrer.id]));
      await Constants.usersCollection.doc(referrer.id).update({
        Constants.inviteTokensDoc: inviteTokens,
        Constants.friendsDoc: FieldValue.arrayUnion([userBubble.id])
      });

      if (context.mounted) {
        await UserManager.reloadHome(context);
        debugPrint('(ReferralService) Navigating to new home');
      }
      debugPrint('(ReferralService) Friend added successfully');
    } catch (e) {
      debugPrint('(ReferralService) Error adding friend: $e');
    }
  }
}
