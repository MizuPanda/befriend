import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/models/objects/bubble.dart';
import 'package:befriend/providers/visibility_settings_provider.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../../models/objects/friendship_progress.dart';
import '../../../utilities/app_localizations.dart';

class VisibilityDialog {
  static void showVisibilityDialog(BuildContext context,
      {required bool isAllPublic,
      required bool isPrivate,
      required Set<FriendshipProgress> friendships}) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: width * Constants.pictureDialogWidthMultiplier,
            height: height * Constants.pictureDialogHeightMultiplier,
            child: VisibilitySettingsWidget(
              isAllPublic: isAllPublic,
              isPrivate: isPrivate,
              friendships: friendships,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                AppLocalizations.translate(context,
                    key: 'dialog_close', defaultString: 'Close'),
                style: GoogleFonts.openSans(fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class VisibilitySettingsWidget extends StatefulWidget {
  final bool isAllPublic;
  final bool isPrivate;
  final Set<FriendshipProgress> friendships;

  const VisibilitySettingsWidget({
    super.key,
    required this.isAllPublic,
    required this.isPrivate,
    required this.friendships,
  });

  @override
  State<VisibilitySettingsWidget> createState() =>
      _VisibilitySettingsWidgetState();
}

class _VisibilitySettingsWidgetState extends State<VisibilitySettingsWidget> {
  final VisibilitySettingsProvider _provider = VisibilitySettingsProvider();

  @override
  void initState() {
    _provider.initWidgetState(
        widget.friendships.map((progress) => progress.friendId()));
    super.initState();
  }

  @override
  void dispose() {
    _provider.disposeWidgetState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      Widget headerIcon;
      String message;

      if (widget.isAllPublic) {
        headerIcon =
            Icon(Icons.public_rounded, color: Colors.green[900], size: 60);
        message = AppLocalizations.translate(context,
            key: 'vsd_public', defaultString: 'Visible to everyone');
      } else if (widget.isPrivate) {
        headerIcon = Icon(Icons.lock_rounded, color: Colors.red[900], size: 60);
        message = AppLocalizations.translate(context,
            key: 'vsd_private',
            defaultString:
                'Visible only to you and the friends you took it with');
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.center,
              child: Icon(Icons.group_rounded, size: 35),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppLocalizations.translate(context,
                    key: 'vsd_protected',
                    defaultString:
                        'These friends will be able to see the picture:'),
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ChangeNotifierProvider.value(
                value: _provider,
                builder: (BuildContext context, Widget? child) {
                  return Consumer<VisibilitySettingsProvider>(builder:
                      (BuildContext context,
                          VisibilitySettingsProvider provider, Widget? child) {
                    return Expanded(
                      child: PagedListView<int, Bubble>(
                        pagingController: provider.pagingController,
                        builderDelegate: PagedChildBuilderDelegate<Bubble>(
                          itemBuilder: (context, user, index) => ListTile(
                            leading: CircleAvatar(backgroundImage: user.avatar),
                            title: Text(
                              user.username,
                              style: GoogleFonts.openSans(),
                            ),
                          ),
                          firstPageProgressIndicatorBuilder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                          newPageProgressIndicatorBuilder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                          noItemsFoundIndicatorBuilder: (context) => Center(
                            child: Text(
                              AppLocalizations.translate(context,
                                  key: 'vsd_none',
                                  defaultString: 'No friends found.'),
                              style: GoogleFonts.openSans(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                }),
          ],
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          headerIcon,
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AutoSizeText(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: widget.isPrivate ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    });
  }
}
