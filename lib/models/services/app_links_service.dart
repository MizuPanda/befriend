import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/models/services/referral_service.dart';
import 'package:befriend/models/services/share_service.dart';
import 'package:befriend/models/services/simple_encryption_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utilities/constants.dart';
import '../qr/qr.dart';

class AppLinksService {
  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _linkSubscription;

  static Future<void> initDeepLinks(BuildContext context) async {
    try {
      // Check initial link if app was in cold state (terminated)
      final Uri? appLink = await _appLinks.getInitialLink();
      if (appLink != null) {
        Uri uri = Uri.parse(appLink.toString());
        if (context.mounted) {
          _handleDeepLink(uri, context);
        }
      }

      // Handle link when app is in warm state (front or background)
      _linkSubscription = _appLinks.uriLinkStream.listen((uriValue) {
        debugPrint(' (AppLinksService) you will listen any url updates ');
        _handleDeepLink(uriValue, context);
      }, onDone: () {
        _linkSubscription?.cancel();
      });
    } catch (e) {
      debugPrint('(AppLinksService) error : $e');
    }
  }

  static Future<void> _handleDeepLink(Uri uri, BuildContext context) async {
    try {
      debugPrint('(AppLinksService) Deep link received: $uri');
      // Extracting path and query parameters

      if (isJoinLink(uri) && AuthenticationManager.isConnected()) {
        String data = SimpleEncryptionService.getDecryptedURI(
            uri, Constants.dataParameter);

        if (data.contains(Constants.appID)) {
          List<String> values = data.split(Constants.dataSeparator);
          if (values.length == 3) {
            String id = values[1];

            String dateTimeParse = values.last;

            if (QR.isExpired(dateTimeParse)) {
              await QR.joinSession(id, context, fromBarcode: false);
            }
          }
        }
      } else if (_isReferralLink(uri) && AuthenticationManager.isConnected()) {
        final String referrerData = SimpleEncryptionService.getDecryptedURI(
            uri, Constants.referrerDataParameter);
        final List<String> data = referrerData.split(Constants.dataSeparator);
        final String referrerId = data.first;
        final String token = data.last;

        debugPrint('(AppLinksService) referrerId=$referrerId, token=$token');

        // Validate the token
        await ReferralService.validateToken(referrerId, token, context);
      } else if (_isPostShareLink(uri) && AuthenticationManager.isConnected()) {
        final String postShareData = SimpleEncryptionService.getDecryptedURI(
            uri, Constants.postShareParameter);
        final List<String> data = postShareData.split(Constants.dataSeparator);
        final String pictureId = data.first;
        final String profileId = data.last;
        debugPrint(
            '(AppLinksService) pictureId=$pictureId, profileId=$profileId');

        await ShareService.handlePostShare(context, pictureId, profileId);
      } else {
        // Handle other paths or default
        debugPrint('(AppLinksService) Not supported URI');
      }
    } catch (e) {
      debugPrint('(AppLinksService) Error handling deep link: $e');
    }
  }

  static bool isJoinLink(Uri uri) {
    return uri.path == '/${Constants.joinPath}' &&
        uri.queryParameters.containsKey('data');
  }

  static bool _isReferralLink(Uri uri) {
    return uri.path == '/${Constants.referralPath}' &&
        uri.queryParameters.containsKey(Constants.referrerDataParameter);
  }

  static bool _isPostShareLink(Uri uri) {
    return uri.path == '/${Constants.postSharePath}' &&
        uri.queryParameters.containsKey(Constants.postShareParameter);
  }
}
