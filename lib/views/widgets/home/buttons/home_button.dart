import 'package:befriend/utilities/samples.dart';
import 'package:flutter/material.dart';

import '../../../../models/home.dart';
import '../../../pages/home_page.dart';

class HomeButton extends StatefulWidget {
  const HomeButton({
    super.key,
  });

  @override
  State<HomeButton> createState() => _HomeButtonState();
}

class _HomeButtonState extends State<HomeButton> {
  static const double _size = 20;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      margin: const EdgeInsets.only(bottom: 90, left: 15),
      child: Container(
        width: _size + 25,
        height: _size + 25,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black, blurRadius: 0.25, offset: Offset(0.5, 1))
          ],
          color: Colors.white,
        ),
        child: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                    home: Home(
                        user: BubbleSample.connectedUser, connectedHome: true)),
              ),
            );
          },
          icon: const Icon(
            Icons.home_rounded,
            color: Colors.black,
            size: _size,
          ),
        ),
      ),
    );
  }
}
