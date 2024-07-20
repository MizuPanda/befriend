import 'package:flutter/material.dart';

import '../../../../utilities/constants.dart';

class RoundButton extends StatelessWidget {
  const RoundButton({super.key, required this.onPressed, required this.data});

  final Function onPressed;
  final IconData data;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    return Container(
      alignment: Alignment.bottomLeft,
      margin: EdgeInsets.only(
          bottom: Constants.homeButtonBottomPaddingMultiplier * height,
          left: width * Constants.homeHorizontalPaddingMultiplier),
      child: Container(
        width: Constants.homeButtonSize + Constants.homeButtonAddSize,
        height: Constants.homeButtonSize + Constants.homeButtonAddSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black, blurRadius: 0.25, offset: Offset(0.5, 1))
          ],
          color: Colors.white,
        ),
        child: IconButton(
          onPressed: () async {
            onPressed();
          },
          icon: Icon(
            data,
            color: Colors.black,
            size: Constants.homeButtonSize,
          ),
        ),
      ),
    );
  }
}
