import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PictureButton extends StatelessWidget {
  const PictureButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.bottomCenter,
        margin: const EdgeInsets.only(bottom: 12),
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
                    return Colors.lightBlueAccent;
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
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                // Add your button press logic here
              },
              child: Stack(
                children: [
                  Transform.translate(
                    offset: const Offset(0.5, 0.5),
                    child: Text(
                      'Take a picture',
                      style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 26,
                              color: Colors.black)),
                    ),
                  ),
                  Text(
                    'Take a picture',
                    style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 26,
                    )),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
