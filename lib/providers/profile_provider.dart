import 'package:flutter/cupertino.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../models/objects/bubble.dart';
import '../models/data/picture_manager.dart';

class ProfileProvider extends ChangeNotifier {
  String? _imageUrl;
  Future<void> changeProfilePicture(
      BuildContext context, Bubble bubble, Function notifyParent) async {
    await PictureManager.showChoiceDialog(context, (String? url) {
      _imageUrl = url;
    });
    if (context.mounted) {
      await _loadPictureChange(context, _imageUrl, bubble, notifyParent);
    }
  }

  Future<void> _loadPictureChange(BuildContext context, String? imageUrl,
      Bubble bubble, Function notifyParent) async {
    if (_imageUrl == null) {
      if (context.mounted) {
        showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.error(
              maxLines: 1,
              message: "Picture change cancelled",
            ),
            snackBarPosition: SnackBarPosition.bottom);
      }
    } else {
      debugPrint('Changing avatar...');
      await PictureManager.changeMainPicture(_imageUrl!, bubble);
      notifyListeners();
      notifyParent();
    }
  }
}
