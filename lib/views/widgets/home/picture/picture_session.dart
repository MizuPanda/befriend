import 'package:befriend/providers/session_provider.dart';
import 'package:befriend/views/widgets/home/picture/sliders.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../models/objects/host.dart';

class PictureSession extends StatefulWidget {
  const PictureSession({super.key, required this.host});

  final Host host;

  @override
  State<PictureSession> createState() => _PictureSessionState();
}

class _PictureSessionState extends State<PictureSession> {
  late final SessionProvider _provider = SessionProvider.builder(widget.host);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _provider.initPicture();
    });
    super.initState();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SessionProvider>.value(
        value: _provider,
        builder: (BuildContext context, Widget? child) {
          return Consumer(builder:
              (BuildContext context, SessionProvider provider, Widget? child) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                leading: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(
                        left: 6), // Reduce or remove padding
                  ),
                  onPressed: () async {
                    await provider.cancelLobby(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                  ),
                ),
              ),
              body: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      '${provider.hostUsername()} is taking a picture!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                        fontSize: 20,
                      )),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: 250, // for full width
                      height: 250.0,
                      decoration: BoxDecoration(
                        // Add any decoration properties here
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.black),
                      ),
                      child: provider.imageNull()
                          ? const Center(
                              child: Icon(Icons.camera),
                            )
                          : provider.image(),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Text(
                      'Users list',
                      style: GoogleFonts.openSans(
                          textStyle: const TextStyle(fontSize: 18)),
                    ),
                    const Expanded(child: UserSlidersScreen()),
                    if (provider.host.main())
                      Container(
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.all(10),
                        child: TextButton(
                          onPressed:
                              provider.length() >= 2 ? () async {} : null,
                          child: Text(
                            'Publish the picture',
                            style: GoogleFonts.openSans(
                                textStyle: const TextStyle(fontSize: 16)),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            );
          });
        });
  }
}
