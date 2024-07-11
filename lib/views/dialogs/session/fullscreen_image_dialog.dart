import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullscreenImageDialog {
  static Future<void> showImageFullScreen(
      BuildContext context, NetworkImage networkImage) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor:
            Colors.transparent, // Make Dialog background transparent
        child: PhotoView(
          tightMode: true,
          backgroundDecoration: const BoxDecoration(
            color: Colors.transparent, // Make PhotoView background transparent
          ),
          // You can adjust the min/max scale if needed
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.contained,
          enableRotation: false,
          imageProvider: networkImage,
        ),
      ),
    );
  }
}
