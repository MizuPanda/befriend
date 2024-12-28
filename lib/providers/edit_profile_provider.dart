import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/utilities/error_handling.dart';
import 'package:flutter/material.dart';

import '../models/authentication/authentication.dart';
import '../models/data/picture_manager.dart';
import '../models/objects/bubble.dart';
import '../utilities/app_localizations.dart';
import '../utilities/constants.dart';
import '../utilities/validators.dart';

class EditProfileProvider extends ChangeNotifier {
  final GlobalKey<FormState> _usernameKey = GlobalKey();
  final GlobalKey<FormState> _bioKey = GlobalKey();

  GlobalKey get usernameKey => _usernameKey;
  GlobalKey get bioKey => _bioKey;

  late Bubble _currentUser;

  String get oldUsername => _currentUser.username;
  String get oldBio => _currentUser.bio;

  String _currentUsername = '';
  String _currentBio = '';

  String? _usernameError;

  bool _isLoading = false;
  bool _isEditLoading = false;
  bool _isRemoveLoading = false;

  bool get isLoading => _isLoading;
  bool get isEditLoading => _isEditLoading;
  bool get isRemoveLoading => _isRemoveLoading;

  ImageProvider avatar() {
    return _currentUser.avatar;
  }

  Future<String> initWidgetState() async {
    try {
      _currentUser = await UserManager.getInstance();

      return 'Completed';
    } catch (e) {
      debugPrint('(EditProfileProvider) Error on init $e');

      rethrow;
    }
  }

  Future<void> saveProfile(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('(EditProfileProvider) Saving Profile');
      _usernameKey.currentState?.save();
      _bioKey.currentState?.save();

      if (_currentUsername != _currentUser.username) {
        if (_usernameKey.currentState!.validate()) {
          bool usernameAvailable =
              await AuthenticationManager.checkUsernameAvailability(
                  _currentUsername);
          if (!usernameAvailable) {
            _usernameError = Constants.usernameError;
            _usernameKey.currentState!.validate();
          } else {
            await _updateUsername();
          }
        }
      }

      if (_currentBio != _currentUser.bio) {
        if (_bioKey.currentState!.validate()) {
          await _updateBio();
        }
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandling.showError(
            context,
            AppLocalizations.translate(context,
                key: 'general_error_message6',
                defaultString:
                    'There was an unexpected error. Please try again.'));
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  void onUsernameSaved(String? value) {
    if (value != null) {
      _currentUsername = value.trim();
    }
  }

  void onBioSaved(String? value) {
    if (value != null) {
      debugPrint('(EditProfileProvider) Value = $value');
      _currentBio = value.trim();
    }
  }

  String? usernameValidator(String? username, BuildContext context) {
    String? validator = Validators.usernameValidator(username, context);

    if (validator != null) {
      return validator;
    }

    if (_usernameError == Constants.usernameError) {
      _usernameError = null;
      return AppLocalizations.translate(context,
          key: 'snp_username_used',
          defaultString: "This username is already in use.");
    }

    return null;
  }

  String? bioValidator(String? bio, BuildContext context) {
    return Validators.bioValidator(bio, context);
  }

  Future<void> _updateUsername() async {
    try {
      await DataQuery.updateDocument(Constants.usernameDoc, _currentUsername);
      UserManager.updateUsername(_currentUsername);
      debugPrint('(EditProfileProvider) Updated username to $_currentUsername');
    } catch (e) {
      debugPrint('(EditProfileProvider) Error while updating username: $e');
      rethrow;
    }
  }

  Future<void> _updateBio() async {
    try {
      await DataQuery.updateDocument(Constants.bioDoc, _currentBio);
      UserManager.updateBio(_currentBio);
      UserManager.notify();
      debugPrint('(EditProfileProvider) Updated bio from to $_currentBio');
    } catch (e) {
      debugPrint('(EditProfileProvider) Error while updating bio: $e');
      rethrow;
    }
  }

  Future<void> changeAvatar(BuildContext context) async {
    try {
      await PictureManager.takeProfilePicture(context,
          (String? imageUrl) async {
        _isEditLoading = true;
        notifyListeners();

        if (imageUrl != null) {
          await PictureManager.changeMainPicture(context, imageUrl);
          UserManager.notify();
          notifyListeners();
        }

        _isEditLoading = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('(EditProfileProvider) Error changing image: $e');
    }
  }

  Future<void> removeAvatar(BuildContext context) async {
    _isRemoveLoading = true;
    notifyListeners();
    try {
      await PictureManager.removeMainPicture(context);
      UserManager.notify();
    } catch (e) {
      debugPrint('(EditProfileProvider) Error removing avatar: $e');
      if (context.mounted) {
        ErrorHandling.showError(
            context,
            AppLocalizations.translate(context,
                key: 'general_error_message6',
                defaultString:
                    'There was an unexpected error. Please try again.'));
      }
    }
    _isRemoveLoading = false;
    notifyListeners();
  }
}
