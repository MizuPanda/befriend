import 'package:befriend/providers/picture_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PictureSignPage extends StatefulWidget {
  const PictureSignPage({super.key});

  @override
  State<PictureSignPage> createState() => _PictureSignPageState();
}

class _PictureSignPageState extends State<PictureSignPage> {
  final PictureSignProvider _provider = PictureSignProvider();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: _provider,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: PictureSignProvider.foregroundColor,
            title: Text(
              'Last step',
              style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                fontSize: 30.0,
                color: Colors.white,
              )),
            ),
            centerTitle: true,
          ),
          backgroundColor:
              const Color(0xFFF4ECE2), // Adjust the color based on your needs.
          body: Center(
            child: Consumer(builder: (BuildContext context,
                PictureSignProvider provider, Widget? child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: _provider.imageNull()
                        ? const EdgeInsets.all(50)
                        : EdgeInsets.zero,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 5,
                          color: PictureSignProvider.foregroundColor,
                        )),
                    child: Builder(builder: (context) {
                      if (_provider.imageNull()) {
                        return const Icon(
                          Icons.camera_alt_outlined,
                          size: 60.0,
                          color: PictureSignProvider.foregroundColor,
                        );
                      }
                      return CircleAvatar(
                          radius: 100, backgroundImage: _provider.image());
                    }),
                  ),
                  const SizedBox(height: 30.0),
                  Text('Almost Done!',
                      style: GoogleFonts.inter(
                        textStyle: const TextStyle(
                          fontSize: 40.0,
                          fontWeight: FontWeight.bold,
                          color: PictureSignProvider.foregroundColor,
                        ),
                      )),
                  const SizedBox(height: 10.0),
                  Container(
                    width: 10.0, // Adjust the size as needed
                    height: 10.0, // Adjust the size as needed
                    decoration: const BoxDecoration(
                      color: PictureSignProvider.foregroundColor,
                      // Change the color as needed
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.0),
                      border: Border.all(
                        color: PictureSignProvider.foregroundColor,
                        width: 4.0,
                      ),
                    ),
                    child: Text('Add a photo to personalize your profile.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            fontSize: 20.0,
                            color: PictureSignProvider.foregroundColor,
                          ),
                        )),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: PictureSignProvider.foregroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 15),
                    ),
                    onPressed: () async {
                      await _provider.retrieveImage(context);
                    },
                    child: const Text('Capture Photo'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 240,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: () async {
                              await _provider.skipHome(context);
                            },
                            child: const Text(
                              'Skip',
                              style: TextStyle(
                                  color: PictureSignProvider.foregroundColor,
                                  fontSize: 16),
                            )),
                        const Spacer(),
                        TextButton(
                            onPressed: _provider.imageNull()
                                ? null
                                : () async {
                                    await _provider.continueHome(context);
                                  },
                            child: const Text(
                              'Confirm',
                              style: TextStyle(
                                  color: PictureSignProvider.foregroundColor,
                                  fontSize: 16),
                            ))
                      ],
                    ),
                  )
                ],
              );
            }),
          ),
        ));
  }
}
