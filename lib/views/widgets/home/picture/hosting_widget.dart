import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/objects/bubble.dart';
import '../../../../models/objects/host.dart';
import '../../../../providers/hosting_provider.dart';
import '../../../../utilities/constants.dart';
import 'columns/hosting.dart';
import 'columns/picture.dart';

class HostingWidget extends StatefulWidget {
  final bool isHost;
  final Bubble? host;

  const HostingWidget({Key? key, required this.isHost, required this.host})
      : super(key: key);

  @override
  State<HostingWidget> createState() => _HostingWidgetState();
}

class _HostingWidgetState extends State<HostingWidget> {
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
  }

  @override
  void dispose() {
    _provider.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: _provider,
        child: Consumer(builder:
            (BuildContext context, HostingProvider provider, Widget? child) {
          return SizedBox(
            width: Constants.pictureDialogWidth,
            height: Constants.pictureDialogHeight,
            child: FutureBuilder(
                future: _hostingFuture,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return Stack(
                      children: [
                        Builder(builder: (
                          BuildContext context,
                        ) {
                          switch (provider.state()) {
                            case HostState.hosting:
                              return const HostingColumn();
                            case HostState.picture:
                              return const PictureColumn();
                          }
                        }),
                        if (provider.isMain() &&
                            provider.state() == HostState.hosting)
                          Positioned(
                            top: 5,
                            right: 5,
                            child: IconButton(
                              icon: const Icon(Icons.qr_code), // QR code icon
                              onPressed: () {
                                provider.showQR(context);
                              },
                            ),
                          ),
                      ],
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          );
        }));
  }
}

//
