import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class BefriendWidget extends StatelessWidget {
  const BefriendWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: BefriendTitle(),
      ),
    );
  }
}

class BefriendTitle extends StatelessWidget {
  const BefriendTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text('Befriend',
        style: GoogleFonts.comingSoon(
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
        ));
  }
}
