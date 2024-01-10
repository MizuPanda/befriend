import 'package:befriend/views/widgets/home/picture/columns/sliders.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/hosting_provider.dart';
import '../../../../../utilities/constants.dart';

class PictureColumn extends StatefulWidget {
  const PictureColumn({super.key});

  @override
  State<PictureColumn> createState() => _PictureColumnState();
}

class _PictureColumnState extends State<PictureColumn> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HostingProvider>(builder:
        (BuildContext context, HostingProvider provider, Widget? child) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 5,
          ),
          SizedBox(
            width: Constants.pictureDialogWidth - 100,
            child: Text(
              '${provider.hostUsername()} is taking a picture!',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                  textStyle: const TextStyle(
                fontSize: 20,
              )),
              maxLines: 2,
            ),
          ),
          Container(
            width: 250, // for full width
            height: 250.0,
            decoration: BoxDecoration(
              // Add any decoration properties here
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: provider.imageNull()
                ? const Center(
                    child: Icon(Icons.camera),
                  )
                : provider.image(),
          ),
          Expanded(
              child: UserSlidersScreen(
            ids: provider.joinerIDS(),
          )),
          if (provider.isMain())
            Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(10),
              child: TextButton(
                onPressed: provider.length() >= 2 ? () async {} : null,
                child: Text(
                  'Publish the picture',
                  style: GoogleFonts.openSans(
                      textStyle: const TextStyle(fontSize: 16)),
                ),
              ),
            )
        ],
      );
    });
  }
}
