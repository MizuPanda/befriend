import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/providers/material_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../providers/picture_card_provider.dart';
import '../../../utilities/app_localizations.dart';

class LikeText extends StatelessWidget {
  const LikeText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PictureCardProvider>(builder:
        (BuildContext context, PictureCardProvider provider, Widget? child) {
      return GestureDetector(
        onTap: () async {
          await provider.showLikesDialog(context);
        },
        child: FutureBuilder(
            future: provider.usersThatLiked(context),
            builder: (BuildContext context, AsyncSnapshot<String> data) {
              if (!data.hasData) {
                return Consumer<MaterialProvider>(builder:
                    (BuildContext context, MaterialProvider materialProvider,
                        Widget? child) {
                  final bool isLightMode =
                      materialProvider.isLightMode(context);

                  return Shimmer.fromColors(
                    baseColor:
                        isLightMode ? Colors.grey[300]! : Colors.grey[500]!,
                    highlightColor:
                        isLightMode ? Colors.grey[100]! : Colors.grey[600]!,
                    child: Row(
                      children: [
                        Container(
                          width: 100,
                          height: 13,
                          color: isLightMode ? Colors.white : Colors.black,
                        ),
                        const SizedBox(width: 5),
                        Container(
                          width: 80,
                          height: 13,
                          color: isLightMode ? Colors.white : Colors.black,
                        ),
                      ],
                    ),
                  );
                });
              }
              return AutoSizeText.rich(TextSpan(
                  style: GoogleFonts.openSans(
                      fontSize: 13,
                      color: provider.isLiked
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).primaryColor),
                  children: [
                    TextSpan(
                        text:
                            '${AppLocalizations.translate(context, key: 'lt_liked', defaultString: 'Liked by')} '),
                    TextSpan(
                        text: data.data,
                        style: const TextStyle(fontWeight: FontWeight.bold))
                  ]));
            }),
      );
    });
  }
}
