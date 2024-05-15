import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../../models/objects/bubble.dart';
import '../../../../providers/hosting_provider.dart';
import '../../../../utilities/constants.dart';
import '../../shimmers/hosting_shimmer_screen.dart';
import 'hosting_column.dart';

class HostingWidget extends StatelessWidget {
  const HostingWidget({super.key, required this.isHost, this.host});

  final bool isHost;
  final Bubble? host;

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
        builder: Builder(
            builder: (context) =>
                _HostingWidgetView(isHost: isHost, host: host)));
  }
}

class _HostingWidgetView extends StatefulWidget {
  final bool isHost;
  final Bubble? host;

  const _HostingWidgetView({Key? key, required this.isHost, required this.host})
      : super(key: key);

  @override
  State<_HostingWidgetView> createState() => _HostingWidgetState();
}

class _HostingWidgetState extends State<_HostingWidgetView> {
  final HostingProvider _provider = HostingProvider();
  Future? _hostingFuture;

  @override
  void initState() {
    super.initState();

    BuildContext? myContext;
    if (widget.key is GlobalKey<ScaffoldState>) {
      myContext =
          (widget.key as GlobalKey<ScaffoldState>).currentState?.context;
    }
    _hostingFuture = widget.isHost
        ? _provider.startingHost(myContext ?? context)
        : _provider.startingJoiner(widget.host!, myContext ?? context);
    //_provider.initShowcase(context);
  }

  @override
  void dispose() {
    _provider.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider.value(
        value: _provider,
        child: Consumer(builder:
            (BuildContext context, HostingProvider provider, Widget? child) {
          return SizedBox(
            width: width * Constants.pictureDialogWidthMultiplier,
            height: height * Constants.pictureDialogHeightMultiplier,
            child: FutureBuilder(
                future: _hostingFuture,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 0.005 * height,
                        ),
                        Builder(builder: (
                          BuildContext context,
                        ) {
                          if (provider.isMain()) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons
                                      .help_outline_rounded), // QR code icon
                                  onPressed: () {
                                    provider.showCase(context);
                                  },
                                ),
                                SizedBox(
                                  width: (width - 130) *
                                      Constants.pictureDialogWidthMultiplier,
                                  child: AutoSizeText(
                                    '${provider.hostUsername()} will take a picture!',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.openSans(
                                        textStyle: const TextStyle(
                                      fontSize: 20,
                                    )),
                                    maxLines: 2,
                                  ),
                                ),
                                Showcase(
                                  key: provider.one,
                                  descriptionAlignment: TextAlign.center,
                                  description:
                                      "Press here to display your QR code. Your friends can scan it to join the photo session.",
                                  child: IconButton(
                                    icon: const Icon(
                                        Icons.qr_code), // QR code icon
                                    onPressed: () {
                                      provider.showQR(context);
                                    },
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: (width - 130) *
                                      Constants.pictureDialogWidthMultiplier,
                                  child: AutoSizeText(
                                    '${provider.hostUsername()} will take a picture!',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.openSans(
                                        textStyle: const TextStyle(
                                      fontSize: 20,
                                    )),
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            );
                          }
                        }),
                        const Expanded(child: HostingColumn()),
                        if (provider.isMain())
                          Container(
                            alignment: Alignment.bottomRight,
                            padding: EdgeInsets.all(0.022 * width),
                            child: Showcase(
                              key: provider.two,
                              description:
                                  "Once all users are connected, tap 'Continue' to proceed.",
                              child: TextButton(
                                onPressed: provider.length() >= 2
                                    ? () async {
                                        await provider.startSession();
                                      }
                                    : null,
                                child: provider.isLoading
                                    ? const CircularProgressIndicator()
                                    : AutoSizeText(
                                        'Continue',
                                        style: GoogleFonts.openSans(
                                            textStyle:
                                                const TextStyle(fontSize: 16)),
                                      ),
                              ),
                            ),
                          ),
                      ],
                    );
                  } else {
                    return const HostingShimmerScreen();
                  }
                }),
          );
        }));
  }
}
