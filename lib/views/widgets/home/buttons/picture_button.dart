import 'package:befriend/views/widgets/home/picture/hosting_widget.dart';
import 'package:befriend/views/widgets/home/picture/joining_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../picture/rounded_dialog.dart';

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
    return AnimatedPositioned(
      //duration: const Duration(milliseconds: 500),
      right: -dragPosition,
      left: dragPosition,
      bottom: 12,
      duration:
          const Duration(milliseconds: 300), // Keeps the button at the bottom
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 54,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isJoinMode
                      ? const [
                          Color.fromRGBO(203, 98, 98, 1.0),
                          Color.fromRGBO(213, 18, 18, 1.0),
                          Color.fromRGBO(203, 98, 98, 1.0),
                        ]
                      : const [
                          Color.fromRGBO(109, 146, 208, 1.0),
                          Color.fromRGBO(0, 73, 243, 1.0),
                          Color.fromRGBO(109, 146, 208, 1.0),
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(25.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isJoinMode
                        ? const Color.fromRGBO(213, 18, 18, 1.0)
                            .withOpacity(0.2)
                        : const Color.fromRGBO(0, 73, 243, 1.0)
                            .withOpacity(0.2),
                    spreadRadius: 4,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]),
            child: GestureDetector(
              onTap: () {
                if (isJoinMode) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const RoundedDialog(child: JoiningWidget());
                      });
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const RoundedDialog(
                          child: HostingWidget(isHost: true, host: null),
                        );
                      });
                }
              },
              child: Center(
                child: Text(
                  isJoinMode ? 'Join a picture' : 'Take a picture',
                  style: GoogleFonts.openSans(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
