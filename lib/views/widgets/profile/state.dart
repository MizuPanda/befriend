import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/bubble.dart';

class ProfileState extends StatelessWidget {
  const ProfileState({
    super.key,
    required this.user,
  });

  final Bubble user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, color: Colors.yellow),
        const SizedBox(width: 8),
        Text('${user.levelText()}: ${user.levelNumberText()}',
            style: GoogleFonts.firaMono(
              textStyle: const TextStyle(fontSize: 16, color: Colors.black),
            )),
      ],
    );
  }
}
