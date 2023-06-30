import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraProvider extends ChangeNotifier {
  static late List<CameraDescription> _cameras;

  late CameraController _controller;
  CameraController get controller => _controller;

  late AnimationController _animationController;
  late FlashState _flashState = FlashState.off;

  IconData lightData() {
    switch (_flashState) {
      case FlashState.on:
        return Icons.flash_on_rounded;
      case FlashState.off:
        return Icons.flash_off_rounded;
      case FlashState.automatic:
        return Icons.flash_auto_rounded;
    }
  }

  late final Animation<double> _tween;
  Animation<double> get tween => _tween;

  /// Initialize the camera controller and the animation controller.
  void init(BuildContext context, TickerProvider vsync) {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: vsync,
    );
    _tween = Tween(begin: 0.0, end: 0.5).animate(_animationController);
    _setCameras(
        context,
        _cameras.firstWhere((description) =>
            description.lensDirection == CameraLensDirection.front));
  }

  /// Dispose the camera controller and the animation controller.
  /// This is done when the user leaves the camera screen.
  void toDispose() {
    _animationController.dispose();
    _controller.dispose();
  }

  /// Set _cameras to the available cameras of the device.
  /// This is done when the app is started.
  static Future<void> availableCamera() async {
    _cameras = await availableCameras();
  }

  /// Changes the flash state of the camera.
  /// The flash state can be on, off or automatic.
  void changeFlashState() {
    switch (_flashState) {
      case FlashState.on:
        _flashState = FlashState.off;
        _controller.setFlashMode(FlashMode.off);
        break;
      case FlashState.off:
        _flashState = FlashState.automatic;
        _controller.setFlashMode(FlashMode.auto);
        break;
      case FlashState.automatic:
        _flashState = FlashState.on;
        _controller.setFlashMode(FlashMode.always);
        break;
    }
    notifyListeners();
  }

  /// Ensure that the controller is initialized.
  bool isInitialized() {
    return _controller.value.isInitialized;
  }

  /// Change the camera lens.
  /// This is done when the user wants to switch between the front and back camera.
  /// The camera lens is changed and the camera is reinitialized.
  void changeCameraLens(BuildContext context) {
    final CameraLensDirection lensDirection =
        _controller.description.lensDirection;
    CameraDescription? newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = _cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back);
    } else {
      newDescription = _cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front);
    }
    _setCameras(context, newDescription);
    _handleOnPressed();
  }

  /// Set the camera controller to the given camera description.
  void _setCameras(BuildContext context, CameraDescription cameraDescription) {
    _controller = CameraController(cameraDescription, ResolutionPreset.max);
    _controller.initialize().then((_) {
      if (!context.mounted) {
        return;
      }
      switch (_flashState) {
        case FlashState.on:
          _controller.setFlashMode(FlashMode.always);
          break;
        case FlashState.off:
          _controller.setFlashMode(FlashMode.off);
          break;
        case FlashState.automatic:
          _controller.setFlashMode(FlashMode.auto);
          break;
      }
      notifyListeners();
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  /// Handle the animation for the camera switch button.
  /// This is done when the user wants to switch between the front and back camera.
  /// The animation is played and the camera is switched.
  void _handleOnPressed() {
    if (_animationController.status == AnimationStatus.completed) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  /// Render the camera preview.
  /// The camera preview is scaled depending on the screen size and the camera aspect ratio.
  Widget cameraWidget(context) {
    CameraValue camera = _controller.value;
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
        child: CameraPreview(_controller),
      ),
    );
  }

  void takePicture() {}
}

/// The state of the flash.
enum FlashState { on, off, automatic }
