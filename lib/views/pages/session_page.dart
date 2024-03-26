import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/providers/session_provider.dart';
import 'package:befriend/views/widgets/home/picture/sliders.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/objects/host.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({super.key, required this.host});

  final Host host;

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: ChangeNotifierProvider<SessionProvider>.value(
          value: _provider,
          builder: (BuildContext context, Widget? child) {
            return Consumer(builder: (BuildContext context,
                SessionProvider provider, Widget? child) {
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
                  child: FutureBuilder(
                      future: provider.getFriendshipsMap(),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return Column(
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
                            GestureDetector(
                              onTap: !provider.imageNull()
                                  ? () async {
                                      await provider
                                          .showImageFullScreen(context);
                                    }
                                  : null,
                              onLongPress: provider.host.main()
                                  ? () async {
                                      await provider.pictureProcess();
                                    }
                                  : null,
                              child: Container(
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
                                    : ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image(
                                          image: provider.networkImage(),
                                          fit: BoxFit.cover,
                                        )),
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            Text(
                              'User list',
                              style: GoogleFonts.openSans(
                                  textStyle: const TextStyle(fontSize: 18)),
                            ),
                            const Expanded(child: UserSlidersScreen()),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.people_rounded,
                                  color: Theme.of(context).primaryColor,
                                ),
                                TextButton(
                                  onPressed: () {
                                    provider.showFriendList(context);
                                  },
                                  child: AutoSizeText(
                                      'Who will see the picture',
                                      style: GoogleFonts.openSans(
                                          textStyle:
                                              const TextStyle(fontSize: 14))),
                                ),
                                const Spacer(),
                                if (provider.host.main())
                                  TextButton(
                                    onPressed: provider.length() >= 2 &&
                                            !provider.imageNull()
                                        ? () async {
                                            await provider
                                                .publishPicture(context);
                                          }
                                        : null,
                                    child: AutoSizeText(
                                      'Publish the picture',
                                      style: GoogleFonts.openSans(
                                          textStyle:
                                              const TextStyle(fontSize: 16)),
                                    ),
                                  )
                              ],
                            ),
                          ],
                        );
                      }),
                ),
              );
            });
          }),
    );
  }
}
