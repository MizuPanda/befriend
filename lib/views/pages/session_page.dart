import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/providers/session_provider.dart';
import 'package:befriend/views/widgets/home/picture/sliders.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../models/objects/host.dart';
import '../../providers/material_provider.dart';
import '../../utilities/app_localizations.dart';

class SessionPage extends StatelessWidget {
  const SessionPage({super.key, required this.host});

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: (context) {
        return _SessionPageView(host: host);
      },
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
  bool _isExpanded = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _provider.initPicture(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    _provider.disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final bool isSmallScreen = height < 700; // Adjust based on your criteria for small screens
    debugPrint('(SessionPage) height=$height');

    return PopScope(
      canPop: false,
      child: ChangeNotifierProvider<SessionProvider>.value(
          value: _provider,
          builder: (BuildContext context, Widget? child) {
            return Consumer(builder: (BuildContext context,
                SessionProvider provider, Widget? child) {
              return Consumer(builder: (BuildContext context,
                  MaterialProvider materialProvider, Widget? child) {
                final bool lightMode = materialProvider.isLightMode(context);

                return GestureDetector(
                  onTap: provider.unfocus,
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    appBar: AppBar(
                      leadingWidth: 80,
                      leading: TextButton(
                        onPressed: () async {
                          await provider.cancelLobby(context);
                        },
                        child: AutoSizeText(
                          AppLocalizations.of(context)
                              ?.translate('dialog_cancel') ??
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
                                    '${provider.hostUsername()} ${AppLocalizations.of(context)?.translate('sp_taking') ?? 'is taking a picture!'}',
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
                                    await provider
                                        .pictureProcess(context);
                                  }
                                      : null,
                                  child: Showcase(
                                    key: provider.one,
                                    description: AppLocalizations.of(context)
                                        ?.translate('sp_one') ??
                                        'Hold the picture to retake.',
                                    child: Showcase(
                                      key: provider.two,
                                      description: AppLocalizations.of(context)
                                          ?.translate('sp_two') ??
                                          'Tap the picture to zoom.',
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
                                              image:
                                              provider.networkImage(),
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 32.0 / 448 * width,
                                      vertical: 0.025 * height / 2),
                                  child: Builder(builder: (context) {
                                    if (provider.host.main()) {
                                      return ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxHeight: 0.2 * height -
                                                0.2 *
                                                    MediaQuery.of(context)
                                                        .viewInsets
                                                        .bottom),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: TextField(
                                                onChanged: provider.onChanged,
                                                focusNode: provider.focusNode,
                                                onSubmitted:
                                                provider.onSubmitted,
                                                textInputAction:
                                                TextInputAction.done,
                                                decoration: InputDecoration(
                                                  hintText: AppLocalizations.of(
                                                      context)
                                                      ?.translate(
                                                      'sp_caption_field') ??
                                                      'Enter Caption',
                                                  border:
                                                  const OutlineInputBorder(),
                                                  focusedBorder:
                                                  const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.blue),
                                                  ),
                                                  enabledBorder:
                                                  const OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors.grey),
                                                  ),
                                                  counterText: '',
                                                ),
                                                maxLines: null,
                                                maxLength:
                                                provider.characterLimit,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            ValueListenableBuilder(
                                              valueListenable:
                                              provider.charCountNotifier,
                                              builder:
                                                  (context, charCount, child) {
                                                return Text(
                                                  '$charCount / ${provider.characterLimit}',
                                                  style: const TextStyle(
                                                      color: Colors.grey),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return SizedBox(
                                        width: double.maxFinite,
                                        child: _buildCaption(
                                          provider.host.host.username,
                                          provider.caption(),
                                        ),
                                      );
                                    }
                                  }),
                                ),
                                if (!(isSmallScreen && _isExpanded))
                                  AutoSizeText(
                                    AppLocalizations.of(context)
                                        ?.translate('sp_list') ??
                                        'User list',
                                    style: GoogleFonts.openSans(
                                        textStyle: const TextStyle(fontSize: 18)),
                                  ),
                                if (!(isSmallScreen && _isExpanded))
                                  const Expanded(child: UserSlidersScreen()),
                                if (!(isSmallScreen && _isExpanded))
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
                                        description: AppLocalizations.of(context)
                                            ?.translate('sp_four') ??
                                            'Press to see users that will be able to see the picture.',
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          width: 0.45 * width,
                                          height: 50,
                                          child: TextButton(
                                            onPressed: () {
                                              provider.showFriendList(context);
                                            },
                                            child: AutoSizeText(
                                                AppLocalizations.of(context)
                                                    ?.translate('sp_who') ??
                                                    'Who will see the picture',
                                                style: GoogleFonts.openSans(
                                                    textStyle: const TextStyle(
                                                        fontSize: 14))),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      if (provider.host.main())
                                        Showcase(
                                          key: provider.five,
                                          description: AppLocalizations.of(
                                              context)
                                              ?.translate('sp_five') ??
                                              'Press here to publish the picture.',
                                          child: provider.isLoading
                                              ? const CircularProgressIndicator()
                                              : Container(
                                            alignment:
                                            Alignment.centerRight,
                                            width: 0.4 * width,
                                            height: 50,
                                            child: TextButton(
                                              onPressed: provider.length() >=
                                                  2 &&
                                                  !provider.imageNull()
                                                  ? () async {
                                                await provider
                                                    .publishPicture(
                                                    context);
                                              }
                                                  : null,
                                              child: AutoSizeText(
                                                AppLocalizations.of(context)
                                                    ?.translate(
                                                    'sp_publish') ??
                                                    'Publish the picture',
                                                textAlign: TextAlign.center,
                                                overflow:
                                                TextOverflow.ellipsis,
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
                  ),
                );
              });
            });
          }),
    );
  }

  Widget _buildCaption(String username, String caption) {
    const int truncateLength = 100; // Adjust the length as needed

    if (caption.length <= truncateLength) {
      return AutoSizeText.rich(
        textAlign: TextAlign.start,
        maxLines: null,
        TextSpan(
          children: [
            TextSpan(
              text: username,
              style: GoogleFonts.openSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: ' $caption',
              style: GoogleFonts.openSans(fontSize: 14),
            ),
          ],
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: username,
                  style: GoogleFonts.openSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: _isExpanded ? ' $caption' : ' ${caption.substring(0, truncateLength)}...',
                  style: GoogleFonts.openSans(fontSize: 14),
                ),
              ],
            ),
            maxLines: _isExpanded ? null : 2,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'See less' : 'See more',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    }
  }
}
