import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ProfileCameraPage extends StatefulWidget {
  /// Set _cameras to the available cameras of the device.
  /// This is done when the app is started.
  static Future<void> availableCamera() async {
    _ProfileCameraPageState._cameras = await availableCameras();
  }

  /// Default Constructor
  const ProfileCameraPage({Key? key}) : super(key: key);

  @override
  State<ProfileCameraPage> createState() => _ProfileCameraPageState();
}

class _ProfileCameraPageState extends State<ProfileCameraPage>
    with SingleTickerProviderStateMixin {
  static late List<CameraDescription> _cameras;
  late CameraController _controller;
  late AnimationController _animationController;
  late FlashState _flashState = FlashState.off;

  IconData data = Icons.flash_off_rounded;

  /// Changes the flash state of the camera.
  /// The flash state can be on, off or automatic.
  void changeFlashState() {
    setState(() {
      switch (_flashState) {
        case FlashState.on:
          _flashState = FlashState.off;
          data = Icons.flash_off_rounded;
          _controller.setFlashMode(FlashMode.off);
          break;
        case FlashState.off:
          _flashState = FlashState.automatic;
          data = Icons.flash_auto_rounded;
          _controller.setFlashMode(FlashMode.auto);
          break;
        case FlashState.automatic:
          _flashState = FlashState.on;
          data = Icons.flash_on_rounded;
          _controller.setFlashMode(FlashMode.always);
          break;
      }
    });
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

  /// Initialize the camera controller and the animation controller.
  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _setCameras(
        context,
        _cameras.firstWhere((description) =>
            description.lensDirection == CameraLensDirection.front));
    super.initState();
  }

  /// Dispose the camera controller and the animation controller.
  /// This is done when the user leaves the camera screen.
  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Get the animation for the camera switch button.
  Animation<double> getTween() {
    return Tween(begin: 0.0, end: 0.5).animate(_animationController);
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

  /// Set the camera controller to the given camera description.
  void _setCameras(BuildContext context, CameraDescription cameraDescription) {
    _controller = CameraController(cameraDescription, ResolutionPreset.max);
    _controller.initialize().then((_) {
      if (!context.mounted) {
        return;
      }
      setState(() {
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
      });
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

  /// Render the camera preview.
  /// This is done when the user wants to take a picture.
  /// The camera preview is rendered and the user can take a picture.
  /// The camera preview is scaled depending on the screen size and the camera aspect ratio.
  Widget cameraWidget(context) {
    var camera = _controller.value;
    // fetch screen size
    final size = MediaQuery.of(context).size;

    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * camera.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(_controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        if (!isInitialized()) {
          return Container(
            color: Colors.white,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text('Take a new profile picture.'),
          ),
          body: Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: Column(
                children: [
                  Expanded(child: cameraWidget(context)),
                  SizedBox(
                    height: 195,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RotationTransition(
                          turns: getTween(),
                          child: RoundButton(
                            size: 50,
                            icon: Icons.autorenew_rounded,
                            colorUnpressed: Colors.white,
                            onPressed: () {
                              changeCameraLens(context);
                            },
                          ),
                        ),
                        RoundButton(
                          icon: data,
                          onPressed: changeFlashState,
                          size: 50,
                          colorUnpressed: Colors.white,
                          borderColor: Colors.transparent,
                        ),
                        RoundButton(
                            size: 50,
                            icon: Icons.circle_rounded,
                            shouldGrow: true,
                            colorUnpressed: Colors.white,
                            colorPressed: Colors.pink.withOpacity(0.7),
                            onPressed: () {
                              //TAKING PICTURE FUNCTION
                            }),
                      ],
                    ),
                  )
                ],
              )),
        );
      },
    );
  }
}

/// The state of the flash.
enum FlashState { on, off, automatic }

class RoundButton extends StatefulWidget {
  final IconData icon;
  final Function onPressed;
  final double size;
  final Color? colorPressed;
  final Color? colorUnpressed;
  final bool? shouldGrow;
  final Color? borderColor;
  const RoundButton(
      {Key? key,
      required this.icon,
      required this.onPressed,
      required this.size,
      this.colorPressed,
      this.colorUnpressed,
      this.shouldGrow,
      this.borderColor})
      : super(key: key);

  @override
  State<RoundButton> createState() => _RoundButtonState();
}

class _RoundButtonState extends State<RoundButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (TapUpDetails details) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 3,
              color: widget.borderColor == null
                  ? Colors.white
                  : widget.borderColor!,
            )),
        child: IconButton(
          color: widget.colorPressed != null
              ? (!_isPressed ? widget.colorUnpressed : widget.colorPressed)
              : widget.colorUnpressed,
          alignment: Alignment.center,
          onPressed: () {
            widget.onPressed();
          },
          icon: Icon(widget.icon),
          iconSize: widget.shouldGrow != null
              ? (widget.shouldGrow!
                  ? (_isPressed ? widget.size * 1.2 : widget.size)
                  : widget.size)
              : widget.size,
        ),
      ),
    );
  }
}
