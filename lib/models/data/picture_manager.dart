import 'dart:io';

import 'package:befriend/models/data/picture_query.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/utilities/error_handling.dart';
import 'package:befriend/views/dialogs/profile/picture_choice_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../objects/bubble.dart';

class PictureManager {
  static const int _sessionQuality = 20;
  static const int _profilePictureQuality = 10;

  static Future<void> changeMainPicture(
      BuildContext context, String path, Bubble bubble) async {
    try {
      File file = File(path);
      String? downloadUrl = await PictureQuery.uploadAvatar(file);
      if (downloadUrl != null) {
        bubble.avatar = await UserManager.refreshAvatar(file);
      }
    } catch (e) {
      debugPrint('(PictureManager): Error changing main picture: $e');
      // Maybe inform the user with a UI update
      if (context.mounted) {
        ErrorHandling.showError(context,
            'Failed to update your profile picture. Please try again.');
      }
    }
  }

  static Future<void> _askCameraPermission() async {
    bool isGranted = await Permission.camera.isGranted;

    if (!isGranted) {
      await Permission.camera
          .onDeniedCallback(() {})
          .onGrantedCallback(() {})
          .onPermanentlyDeniedCallback(() {
            openAppSettings();
          })
          .onRestrictedCallback(() {})
          .onLimitedCallback(() {})
          .onProvisionalCallback(() {})
          .request();
    }
  }

  static Future<void> takeSessionPicture(
    BuildContext context,
    Function(String?) onImageSelected,
  ) async {
    await _showChoiceDialog(context, onImageSelected,
        imageQuality: _sessionQuality);
  }

  static Future<void> takeProfilePicture(
    BuildContext context,
    Function(String?) onImageSelected,
  ) async {
    await _showChoiceDialog(context, onImageSelected,
        imageQuality: _profilePictureQuality);
  }

  static Future<void> _showChoiceDialog(
      BuildContext context, Function(String?) onImageSelected,
      {required int imageQuality}) async {
    if (context.mounted) {
      await PictureChoiceDialog.showPictureChoiceDialog(context, () async {
        await _pickImage(ImageSource.gallery, onImageSelected,
            imageQuality: imageQuality);
        if (context.mounted) {
          Navigator.of(context).pop(); // Close the dialog
        }
      }, () async {
        await _pickImage(ImageSource.camera, onImageSelected,
            imageQuality: imageQuality);
        if (context.mounted) {
          Navigator.of(context).pop(); // Close the dialog
        }
      }).catchError((e) {
        debugPrint('(PictureManager): Error showing choice dialog: $e');
        // Handle the error, maybe close the dialog or show an error message
      });
    }
  }

  static Future<void> cameraPicture(
    Function(String?) onImageSelected,
  ) async {
    await _pickImage(ImageSource.camera, onImageSelected,
        imageQuality: _sessionQuality);
  }

  static Future<void> _pickImage(
      ImageSource source, Function(String?) onImageSelected,
      {required int imageQuality}) async {
    try {
      if (source == ImageSource.camera) {
        await _askCameraPermission();
      }

      final pickedImage = await ImagePicker()
          .pickImage(source: source, imageQuality: imageQuality);

      if (pickedImage != null) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          compressQuality: 100,
          sourcePath: pickedImage.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Edit your picture',
                toolbarWidgetColor: Colors.black,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            IOSUiSettings(
              title: 'Edit your picture',
            ),
          ],
        );

        onImageSelected(croppedFile?.path);
      }
    } catch (e) {
      debugPrint('(PictureManager): Failed to pick or crop image: $e');
      onImageSelected(null);
    }
  }
}
