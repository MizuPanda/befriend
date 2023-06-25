import 'package:flutter/material.dart';

import '../../../models/bubble.dart';

class ProfilePictures extends StatelessWidget {
  const ProfilePictures({
    super.key,
    required this.user,
  });
  final Bubble user;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //NEW PICS ON TOP, WITH MAXIMAL HEIGHT/DESIRED FORM, THEN LIST VIEW OF ROWS OF 3 PICTURES
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Container(
            width: 200,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Text('Picture 1')),
          ),
          Container(
            width: 200,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Text('Picture 2')),
          ),
          Container(
            width: 200,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Text('Picture 3')),
          ),
        ],
      ),
    );
  }
}
