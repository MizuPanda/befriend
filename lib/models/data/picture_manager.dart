import 'dart:io';

import 'package:befriend/utilities/constants.dart';
import 'package:befriend/utilities/error_handling.dart';
import 'package:befriend/utilities/models.dart';
import 'package:befriend/views/dialogs/permission_denied_dialog.dart';
import 'package:befriend/views/dialogs/profile/picture_choice_dialog.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utilities/app_localizations.dart';
import '../objects/bubble.dart';

class PictureManager {
  static const int _sessionQuality = 25;
  static const int _profilePictureQuality = 10;

  static Future<void> removeMainPicture(
      BuildContext context, Bubble bubble) async {
    try {
      await Models.pictureQuery.removeProfilePicture(bubble.avatarUrl);
      bubble.avatar = Image.asset(Constants.defaultPictureAddress).image;
    } catch (e) {
      debugPrint('(PictureManager): Error removing main picture: $e');
      if (context.mounted) {
        ErrorHandling.showError(
            context,
            AppLocalizations.of(context)?.translate('pm_mp_error') ??
                'Failed to update your profile picture. Please try again.');
      }
    }
  }

  static Future<void> changeMainPicture(
      BuildContext context, String path, Bubble bubble) async {
    try {
      File file = File(path);
      String? downloadUrl = await Models.pictureQuery.uploadAvatar(file);
      if (downloadUrl != null) {
        bubble.avatar = await Models.userManager.refreshAvatar(file);
      }
    } catch (e) {
      debugPrint('(PictureManager): Error changing main picture: $e');
      if (context.mounted) {
        ErrorHandling.showError(
            context,
            AppLocalizations.of(context)?.translate('pm_mp_error') ??
                'Failed to update your profile picture. Please try again.');
      }
    }
  }

  static Future<void> _requestPermission(
      Permission permission, BuildContext context, String rationale) async {
    PermissionStatus status = await permission.status;

    if (status.isDenied) {
      bool isGranted = await permission.request().isGranted;
      if (!isGranted) {
        if (context.mounted) {
          await PermissionDeniedDialog.showPermissionDeniedDialog(
              context, rationale);
        }
      }
    } else if (status.isPermanentlyDenied) {
      if (context.mounted) {
        await PermissionDeniedDialog.showPermissionDeniedDialog(
            context, rationale);
      }
    }
  }

  static Future<void> takeProfilePicture(
      BuildContext context, Function(String?) onImageSelected) async {
    await _showChoiceDialog(context, onImageSelected,
        imageQuality: _profilePictureQuality);
  }

  static Future<void> _showChoiceDialog(
      BuildContext context, Function(String?) onImageSelected,
      {required int imageQuality}) async {
    if (context.mounted) {
      await PictureChoiceDialog.showPictureChoiceDialog(context, () async {
        await _pickImage(ImageSource.gallery, context, onImageSelected,
            imageQuality: imageQuality);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }, () async {
        await _pickImage(ImageSource.camera, context, onImageSelected,
            imageQuality: imageQuality);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }).catchError((e) {
        debugPrint('(PictureManager): Error showing choice dialog: $e');
      });
    }
  }

  static Future<void> cameraPicture(
    BuildContext context,
    Function(String?) onImageSelected,
  ) async {
    await _pickImage(ImageSource.camera, context, onImageSelected,
        imageQuality: _sessionQuality);
  }

  static Future<void> _pickImage(ImageSource source, BuildContext context,
      Function(String?) onImageSelected,
      {required int imageQuality}) async {
    try {
      if (source == ImageSource.camera) {
        await _requestPermission(
            Permission.camera,
            context,
            AppLocalizations.of(context)?.translate('pm_cam_perm') ??
                'Camera access is needed to take photos.');
      }

      if (source == ImageSource.gallery) {
        if (Platform.isAndroid) {
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          if (androidInfo.version.sdkInt <= 32) {
            /// use [Permissions.storage.status]
            if (context.mounted) {
              await _requestPermission(
                  Permission.storage,
                  context,
                  AppLocalizations.of(context)?.translate('pm_gall_perm') ??
                      'Photo library access is needed to select photos.');
            }
          } else {
            /// use [Permissions.photos.status]
            if (context.mounted) {
              await _requestPermission(
                  Permission.photos,
                  context,
                  AppLocalizations.of(context)?.translate('pm_gall_perm') ??
                      'Photo library access is needed to select photos.');
            }
          }
        }
      }

      final pickedImage = await ImagePicker()
          .pickImage(source: source, imageQuality: imageQuality);

      if (pickedImage != null) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          compressQuality: 100,
          sourcePath: pickedImage.path,
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: context.mounted
                    ? AppLocalizations.of(context)?.translate('pm_edit_pic') ??
                        'Edit your picture'
                    : 'Edit your picture',
                toolbarWidgetColor: Colors.black,
                initAspectRatio: CropAspectRatioPreset.square,
                aspectRatioPresets: [CropAspectRatioPreset.square, CropAspectRatioPreset.original],
                lockAspectRatio: false),
            IOSUiSettings(
                title: context.mounted
                    ? AppLocalizations.of(context)?.translate('pm_edit_pic') ??
                        'Edit your picture'
                    : 'Edit your picture',
              aspectRatioPresets: [CropAspectRatioPreset.square, CropAspectRatioPreset.original],
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
