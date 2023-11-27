import 'package:befriend/views/widgets/home/picture/hosting_widget.dart';
import 'package:befriend/views/widgets/home/picture/joining_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../picture/bluetooth_dialog.dart';

class PictureButton extends StatefulWidget {
  const PictureButton({super.key});

  @override
  State<PictureButton> createState() => _PictureButtonState();
}

class _PictureButtonState extends State<PictureButton> {
  double dragPosition = 0.0;
  bool isJoinMode = false;

  void updateMode() {
    if (dragPosition.abs() > 50) {
      // Switch to join mode if dragged sufficiently to the left
      isJoinMode = !isJoinMode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(),
        ),
        AnimatedPositioned(
          //duration: const Duration(milliseconds: 500),
          right: -dragPosition,
          left: dragPosition,
          bottom: 12,
          duration: const Duration(
              milliseconds: 300), // Keeps the button at the bottom
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                dragPosition += details.delta.dx;
              });
            },
            onHorizontalDragEnd: (details) {
              setState(() {
                updateMode();
                dragPosition = 0.0; // Reset position after drag ends
              });
            },
            child: ElevatedButtonTheme(
              data: ElevatedButtonThemeData(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.white.withOpacity(0.9);
                      } else {
                        return isJoinMode ? Colors.red : Colors.lightBlueAccent;
                      }
                    },
                  ),
                  foregroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.black;
                      } else {
                        return Colors.white;
                      }
                    },
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.only(left: 18, right: 18),
                width: MediaQuery.of(context).size.width,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    if (isJoinMode) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const BluetoothDialog(child: JoiningWidget());

                          }
                      );
                    } else {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const BluetoothDialog(child: HostingWidget(isHost: true, host: null),);
                          }
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      Transform.translate(
                        offset: const Offset(0.5, 0.5),
                        child: Text(
                          isJoinMode ? 'Join a picture' : 'Take a picture',
                          style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 26,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        isJoinMode ? 'Join a picture' : 'Take a picture',
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 26,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

