import 'package:befriend/models/authentication/authentication.dart';
import 'package:befriend/providers/likes_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../../models/data/user_manager.dart';
import '../../../models/objects/bubble.dart';
import '../../../utilities/app_localizations.dart';
import '../../../utilities/constants.dart';

class LikesDialog {
  static Future<void> showLikesDialog(
      BuildContext context, List<dynamic> likes) async {
    try {
      Bubble bubble = await UserManager.getInstance();

      final double width =
          context.mounted ? MediaQuery.of(context).size.width : 250;
      final double height =
          context.mounted ? MediaQuery.of(context).size.height : 600;

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                content: SizedBox(
                    width: width * Constants.pictureDialogWidthMultiplier,
                    height: height * Constants.pictureDialogHeightMultiplier,
                    child: LikesWidget(
                      bubble: bubble,
                      likes: likes,
                    )));
          },
        );
      }
    } catch (e) {
      debugPrint('(PictureCardProvider) Error showing likes dialog: $e');
    }
  }
}

class LikesWidget extends StatefulWidget {
  const LikesWidget({super.key, required this.bubble, required this.likes});

  final Bubble bubble;
  final List<dynamic> likes;

  @override
  State<LikesWidget> createState() => _LikesWidgetState();
}

class _LikesWidgetState extends State<LikesWidget> {
  final LikesProvider _provider = LikesProvider();

  @override
  void initState() {
    _provider.initWidgetState(widget.likes);
    super.initState();
  }

  @override
  void dispose() {
    _provider.disposeWidgetState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_rounded,
              color: Colors.red,
            ),
            Icon(
              Icons.favorite_rounded,
              color: Colors.red,
            ),
            Icon(
              Icons.favorite_rounded,
              color: Colors.red,
            )
          ],
        ),
        ChangeNotifierProvider.value(
            value: _provider,
            builder: (BuildContext context, Widget? child) {
              return Consumer<LikesProvider>(builder: (BuildContext context,
                  LikesProvider provider, Widget? child) {
                return Expanded(
                  child: PagedListView<int, Bubble>(
                    pagingController: provider.pagingController,
                    builderDelegate: PagedChildBuilderDelegate<Bubble>(
                      itemBuilder: (context, user, index) => ListTile(
                        leading: CircleAvatar(backgroundImage: user.avatar),
                        title: Text(
                          user.id == AuthenticationManager.id()
                              ? AppLocalizations.of(context)
                                      ?.translate('general_word_you') ??
                                  'You'
                              : user.username,
                          style: GoogleFonts.openSans(),
                        ),
                      ),
                      firstPageProgressIndicatorBuilder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                      newPageProgressIndicatorBuilder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                      noItemsFoundIndicatorBuilder: (context) => Center(
                        child: Text(
                          AppLocalizations.of(context)?.translate('ld_none') ??
                              'No likes.',
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
}
