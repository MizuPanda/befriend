import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../providers/picture_card_provider.dart';

class LikeText extends StatelessWidget {
  const LikeText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PictureCardProvider>(builder:
        (BuildContext context, PictureCardProvider provider, Widget? child) {
      return TextButton(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(
              Colors.transparent,
            ),
            // Removes splash effect
          ),
          onPressed: () async {
            await provider.showLikesDialog(context);
          },
          child: AutoSizeText.rich(TextSpan(
              style: GoogleFonts.openSans(
                  fontSize: 13,
                  color: provider.isLiked
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).primaryColor),
              children: [
                const TextSpan(text: 'Liked by '),
                TextSpan(
                    text: provider.usersThatLiked(),
                    style: const TextStyle(fontWeight: FontWeight.bold))
              ])));
    });
  }
}
