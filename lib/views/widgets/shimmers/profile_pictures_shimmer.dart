import 'package:befriend/views/widgets/shimmers/picture_card_shimmer.dart';
import 'package:flutter/material.dart';

class ProfilePicturesShimmer extends StatelessWidget {
  const ProfilePicturesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          PictureCardShimmer(),
          PictureCardShimmer(),
          PictureCardShimmer(),
        ],
      ),
    );
  }
}
