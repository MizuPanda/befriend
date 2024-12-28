import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/providers/joining_provider.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/app_localizations.dart';

class JoiningWidget extends StatefulWidget {
  const JoiningWidget({super.key});

  @override
  State<JoiningWidget> createState() => _JoiningWidgetState();
}

class _JoiningWidgetState extends State<JoiningWidget> {
  final JoiningProvider _provider = JoiningProvider();

  @override
  void dispose() {
    super.dispose();
    _provider.disposeState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    final double iconSize = 0.08 * width;

    return ChangeNotifierProvider.value(
        value: _provider,
        builder: (BuildContext context, Widget? child) {
          return Consumer(builder:
              (BuildContext context, JoiningProvider provider, Widget? child) {
            return SizedBox(
              width: width * Constants.pictureDialogWidthMultiplier,
              height: height * Constants.pictureDialogHeightMultiplier,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                    ),
                    child: AutoSizeText(
                      AppLocalizations.translate(context,
                          key: 'jw_scan',
                          defaultString: "Scan your friend's QR Code!"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  Container(
                    height: Constants.pictureDialogHeightMultiplier *
                        0.625 *
                        height,
                    width: Constants.pictureDialogHeightMultiplier *
                        0.625 *
                        height,
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).primaryColor)),
                    child: MobileScanner(
                      // fit: BoxFit.contain,
                      controller: provider.cameraController,
                      onDetect: (capture) async {
                        await provider.handleBarcodeDetection(capture, context);
                      },
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        IconButton(
                          icon: provider.torchEnabled()
                              ? const Icon(Icons.flash_on_outlined,
                                  color: Colors.blue)
                              : const Icon(Icons.flash_off),
                          iconSize: iconSize,
                          onPressed: provider.toggleTorch,
                        ),
                        SizedBox(
                          width: 0.045 * width,
                        ),
                        IconButton(
                          icon: switch (provider.cameraFacing()) {
                            CameraFacing.front => const Icon(
                                Icons.camera_front,
                              ),
                            CameraFacing.back => const Icon(
                                Icons.camera_rear,
                              )
                          },
                          onPressed: provider.switchCamera,
                          iconSize: iconSize,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }
}
