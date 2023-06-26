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
    super.key, this.fontSize
  });

  final double? fontSize;
  @override
  Widget build(BuildContext context) {
    return Text('Befriend',
        style: GoogleFonts.comingSoon(
          textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize ?? 35),
        ));
  }
}
