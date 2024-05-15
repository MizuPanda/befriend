import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/providers/session_provider.dart';
import 'package:befriend/views/widgets/home/picture/sliders.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../models/objects/host.dart';
import '../../providers/material_provider.dart';

class SessionPage extends StatelessWidget {
  const SessionPage({super.key, required this.host});

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: Builder(builder: (context) {
        return _SessionPageView(host: host);
      }),
    );
  }

  final Host host;
}

class _SessionPageView extends StatefulWidget {
  const _SessionPageView({required this.host});

  final Host host;

  @override
  State<_SessionPageView> createState() => _SessionPageState();
}

class _SessionPageState extends State<_SessionPageView> {
  late final SessionProvider _provider = SessionProvider.builder(widget.host);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _provider.initPicture();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: ChangeNotifierProvider<SessionProvider>.value(
          value: _provider,
          builder: (BuildContext context, Widget? child) {
            final double width = MediaQuery.of(context).size.width;
            final double height = MediaQuery.of(context).size.height;

            return Consumer(builder: (BuildContext context,
                SessionProvider provider, Widget? child) {
              return Consumer(builder: (BuildContext context,
                  MaterialProvider materialProvider, Widget? child) {
                final bool lightMode = materialProvider.isLightMode(context);

                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                    leadingWidth: 80,
                    leading: TextButton(
                      onPressed: () async {
                        await provider.cancelLobby(context);
                      },
                      child: const AutoSizeText(
                        'Cancel',
                        maxLines: 1,
                      ),
                    ),
                    actions: [
                      IconButton(
                          onPressed: () {
                            provider.showCase(context);
                          },
                          icon: const Icon(Icons.help_outline_rounded))
                    ],
                  ),
                  body: SafeArea(
                    child: FutureBuilder(
                        future: provider.getFriendshipsMap(context),
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 0.005 * height,
                                ),
                                child: AutoSizeText(
                                  '${provider.hostUsername()} is taking a picture!',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.openSans(
                                      textStyle: const TextStyle(
                                    fontSize: 20,
                                  )),
                                ),
                              ),
                              SizedBox(
                                height: 0.005 * height,
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
                                child: Showcase(
                                  key: provider.one,
                                  description: 'Hold the picture to retake.',
                                  child: Showcase(
                                    key: provider.two,
                                    description: 'Tap the picture to zoom.',
                                    child: Container(
                                      width: 0.7 * width, // for full width
                                      height: 0.7 * width,
                                      decoration: BoxDecoration(
                                        // Add any decoration properties here
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        border: Border.all(
                                            color: lightMode
                                                ? Colors.black
                                                : Colors.white),
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
                                ),
                              ),
                              SizedBox(
                                height: 0.025 * height,
                              ),
                              AutoSizeText(
                                'User list',
                                style: GoogleFonts.openSans(
                                    textStyle: const TextStyle(fontSize: 18)),
                              ),
                              const Expanded(child: UserSlidersScreen()),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 0.022 * width,
                                  ),
                                  Icon(
                                    Icons.people_rounded,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  Showcase(
                                    key: provider.four,
                                    description:
                                        'Press to see users that will be able to see the picture.',
                                    child: TextButton(
                                      onPressed: () {
                                        provider.showFriendList(context);
                                      },
                                      child: AutoSizeText(
                                          'Who will see the picture',
                                          style: GoogleFonts.openSans(
                                              textStyle: const TextStyle(
                                                  fontSize: 14))),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (provider.host.main())
                                    Showcase(
                                      key: provider.five,
                                      description:
                                          'Press here to publish the picture.',
                                      child: TextButton(
                                        onPressed: provider.length() >= 2 &&
                                                !provider.imageNull()
                                            ? () async {
                                                await provider
                                                    .publishPicture(context);
                                              }
                                            : null,
                                        child: Center(
                                          child: provider.isLoading
                                              ? const CircularProgressIndicator()
                                              : AutoSizeText(
                                                  'Publish the picture',
                                                  style: GoogleFonts.openSans(
                                                      textStyle:
                                                          const TextStyle(
                                                              fontSize: 16)),
                                                ),
                                        ),
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
            });
          }),
    );
  }
}
