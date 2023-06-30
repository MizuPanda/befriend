import 'package:befriend/providers/camera_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class CameraWidget extends StatelessWidget {
  const CameraWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraProvider>(builder:
        (BuildContext context, CameraProvider provider, Widget? child) {
      CameraValue camera = provider.controller.value;
      // fetch screen size
      final Size size = MediaQuery.of(context).size;

      // calculate scale depending on screen and camera ratios
      // this is actually size.aspectRatio / (1 / camera.aspectRatio)
      // because camera preview size is received as landscape
      // but we're calculating for portrait orientation
      double scale = size.aspectRatio * camera.aspectRatio;

      // to prevent scaling down, invert the value
      if (scale < 1) scale = 1 / scale;

      return Transform.scale(
        scale: scale,
        child: Center(
          child: CameraPreview(provider.controller),
        ),
      );
    });
  }
}
