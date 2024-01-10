import 'package:flutter/cupertino.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../models/objects/bubble.dart';
import '../models/data/picture_manager.dart';

class ProfileProvider extends ChangeNotifier {
  String? _imageUrl;
  Future<void> changeProfilePicture(BuildContext context, Bubble bubble) async {
    await PictureManager.showChoiceDialog(context, _imageUrl);
    if (context.mounted) {
      await _loadPictureChange(context, _imageUrl, bubble);
    }
  }

  Future<void> _loadPictureChange(
      BuildContext context, String? imageUrl, Bubble bubble) async {
    if (_imageUrl == null) {
      if (context.mounted) {
        showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(
              maxLines: 1,
              message: "Something went wrong",
            ),
            snackBarPosition: SnackBarPosition.bottom);
      }
    } else {
      debugPrint('Changing avatar...');
      bubble.avatar = await PictureManager.changeMainPicture(_imageUrl!);
      notifyListeners();
    }
  }
}
