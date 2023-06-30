import 'package:befriend/providers/camera_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/camera/camera.dart';
import '../widgets/camera/round_button.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage>
    with SingleTickerProviderStateMixin {
  final CameraProvider _provider = CameraProvider();

  @override
  void initState() {
    _provider.init(context, this);
    super.initState();
  }

  @override
  void dispose() {
    _provider.toDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer(
        builder:
            (BuildContext context, CameraProvider provider, Widget? child) {
          if (!_provider.isInitialized()) {
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
                    const Expanded(child: CameraWidget()),
                    SizedBox(
                      height: 195,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RotationTransition(
                            turns: _provider.tween,
                            child: RoundButton(
                              size: 50,
                              icon: Icons.autorenew_rounded,
                              colorUnpressed: Colors.white,
                              onPressed: () {
                                _provider.changeCameraLens(context);
                              },
                            ),
                          ),
                          RoundButton(
                            icon: _provider.lightData(),
                            onPressed: _provider.changeFlashState,
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
                                _provider.takePicture();
                              }),
                        ],
                      ),
                    )
                  ],
                )),
          );
        },
      ),
    );
  }
}
