import 'dart:io';

import 'package:befriend/models/data/picture_manager.dart';
import 'package:befriend/utilities/error_handling.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/data/picture_query.dart';
import '../models/data/user_manager.dart';
import '../models/objects/home.dart';
import '../utilities/app_localizations.dart';
import '../utilities/constants.dart';

class PictureSignProvider extends ChangeNotifier {
  bool _isSkipLoading = false;
  bool _isContinueLoading = false;

  bool get isSkipLoading => _isSkipLoading;
  bool get isContinueLoading => _isContinueLoading;

  String? _imagePath;

  bool imageNull() {
    return _imagePath == null;
  }

  ImageProvider image() {
    return Image.file(File(_imagePath!)).image;
  }

  Future<void> retrieveImage(BuildContext context) async {
    try {
      await PictureManager.takeProfilePicture(
        context,
        (String? url) {
          _imagePath = url;
        },
      );
      notifyListeners();
    } catch (e) {
      debugPrint('(PictureSignProvider) Error retrieving image: $e');
      if (context.mounted) {
        ErrorHandling.showError(
            context,
            AppLocalizations.translate(context,
                key: 'psp_retrieve_error',
                defaultString: 'Error retrieving image. Please try again.'));
      }
    }
  }

  Future<void> continueHome(BuildContext context) async {
    _isContinueLoading = true;
    notifyListeners();

    try {
      await PictureQuery.uploadAvatar(File(_imagePath!));
      if (context.mounted) {
        await _skip(context);
      }
    } catch (e) {
      debugPrint('(PictureSignProvider) Error uploading avatar: $e');
      if (context.mounted) {
        ErrorHandling.showError(
            context,
            AppLocalizations.translate(context,
                key: 'psd_upload_error',
                defaultString: 'Error uploading avatar. Please try again.'));
      }
    } finally {
      _isContinueLoading = false;
      notifyListeners();
    }
  }

  Future<void> skipHome(BuildContext context) async {
    _isSkipLoading = true;
    notifyListeners();

    try {
      await _skip(context);
    } catch (e) {
      debugPrint('(PictureSignProvider) Error navigating to home: $e');
      if (context.mounted) {
        ErrorHandling.showError(
            context,
            AppLocalizations.translate(context,
                key: 'psp_skip_error',
                defaultString: 'Error navigating to home. Please try again.'));
      }
    } finally {
      _isSkipLoading = false;
      notifyListeners();
    }
  }

  Future<void> _skip(BuildContext context) async {
    try {
      Home user = await UserManager.userHome();
      user.activeTutorial();

      if (context.mounted) {
        GoRouter.of(context).go(Constants.homepageAddress, extra: user);
      }
    } catch (e) {
      rethrow;
    }
  }
}
