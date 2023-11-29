import 'package:befriend/providers/hosting_provider.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:befriend/views/widgets/users/profile_photo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../models/objects/bubble.dart';

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
    BuildContext? myContext;
    if (widget.key is GlobalKey<ScaffoldState>) {
      myContext =
          (widget.key as GlobalKey<ScaffoldState>).currentState?.context;
    }
    _hostingFuture = widget.isHost
        ? _provider.startingHost(myContext ?? context)
        : _provider.startingJoiner(widget.host!, myContext ?? context);
    super.initState();
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              width: Constants.pictureDialogWidth - 100,
                              child: Text(
                                '${provider.hostUsername()} is taking the picture!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.openSans(
                                    textStyle: const TextStyle(
                                  fontSize: 20,
                                )),
                                maxLines: 2,
                              ),
                            ),
                            Expanded(
                                child: ListView.builder(
                              itemCount: provider.length(),
                              itemBuilder: (context, index) {
                                return Builder(builder: (context) {
                                  if (provider.main() &&
                                      provider.indexMain(index)) {
                                    return ListTile(
                                      leading: ProfilePhoto(
                                        user: provider.bubble(index),
                                        radius:
                                            Constants.pictureDialogAvatarSize,
                                      ),
                                      title: Text(provider.name(index)),
                                      subtitle: Text(provider.username(index)),
                                      trailing: IconButton(
                                        onPressed: () async {
                                          await provider.deleteUser(index);
                                        },
                                        icon: const Icon(
                                          Icons.delete_rounded,
                                          color: Colors.red,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return ListTile(
                                      leading: ProfilePhoto(
                                        user: provider.bubble(index),
                                        radius:
                                            Constants.pictureDialogAvatarSize,
                                      ),
                                      title: Text(provider.name(index)),
                                      subtitle: Text(provider.username(index)),
                                    );
                                  }
                                });
                              },
                            )),
                            if (provider.main())
                              Container(
                                alignment: Alignment.bottomRight,
                                padding: const EdgeInsets.all(10),
                                child: TextButton(
                                  onPressed: provider.length() >= 2
                                      ? () {
                                          //TAKE THE PICTURE
                                        }
                                      : null,
                                  child: Text(
                                    'Take the picture',
                                    style: GoogleFonts.openSans(
                                        textStyle:
                                            const TextStyle(fontSize: 16)),
                                  ),
                                ),
                              )
                          ],
                        ),
                        if (provider.main())
                          Positioned(
                            top: 5,
                            right: 5,
                            child: IconButton(
                              icon: const Icon(Icons.qr_code), // QR code icon
                              onPressed: () {
                                provider.showQRCodeDialog(context);
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
