import 'package:flutter/cupertino.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../models/objects/bubble.dart';
import '../models/data/picture_manager.dart';

class ProfileProvider extends ChangeNotifier {

  Future<void> changeProfilePicture(BuildContext context, Bubble bubble) async {
    await PictureManager.showChoiceDialog(context, (CroppedFile? file) {
      _loadPictureChange(context, file, bubble);
    });

  }

  Future<void> _loadPictureChange(BuildContext context, CroppedFile? file, Bubble bubble) async {
    if(file == null) {
      if(context.mounted) {
        showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(
              maxLines: 1,
              message:
              "Something went wrong",
            ),
            snackBarPosition: SnackBarPosition.bottom);
      }
    } else {
      debugPrint('Changing avatar...');
      bubble.avatar = await PictureManager.changeMainPicture(file.path);
      notifyListeners();
    }
  }
}