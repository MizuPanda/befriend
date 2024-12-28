import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/models/objects/friendship.dart';
import 'package:befriend/providers/mutual_provider.dart';
import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:befriend/views/widgets/shimmers/mutual_shimmer.dart';
import 'package:befriend/views/widgets/users/profile_photo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../models/objects/profile.dart';
import '../../utilities/app_localizations.dart';

class MutualPage extends StatefulWidget {
  const MutualPage({
    super.key,
    required this.profile,
  });

  @override
  State<MutualPage> createState() => _MutualPageState();

  final Profile profile;
}

class _MutualPageState extends State<MutualPage> {
  final MutualProvider _provider = MutualProvider();

  @override
  void initState() {
    super.initState();

    _provider.initState(
      loadedFriends: widget.profile.loadedFriends,
      mainUser: widget.profile.currentUser,
      commonIDS: widget.profile.commonIDS,
    );
  }

  @override
  void dispose() {
    _provider.disposeState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const BefriendTitle()),
      body: ChangeNotifierProvider.value(
          value: _provider,
          builder: (BuildContext context, Widget? child) {
            return Consumer(builder:
                (BuildContext context, MutualProvider provider, Widget? child) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AutoSizeText(
                      '${AppLocalizations.translate(context, key: 'mp_friends', defaultString: "Friends you and")} '
                      '${widget.profile.user.username}'
                      '${AppLocalizations.translate(context, key: 'mp_common', defaultString: " have in common")}',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: GoogleFonts.openSans(
                        fontSize: 21,
                      ),
                    ),
                  ),
                  Expanded(
                    child: PagedListView<int, Friendship>(
                      pagingController: provider.pagingController,
                      builderDelegate: PagedChildBuilderDelegate<Friendship>(
                        firstPageProgressIndicatorBuilder:
                            (BuildContext context) {
                          return const MutualShimmer();
                        },
                        newPageProgressIndicatorBuilder:
                            (BuildContext context) {
                          return const MutualShimmer();
                        },
                        noItemsFoundIndicatorBuilder: (BuildContext context) {
                          return const Center();
                        },
                        itemBuilder: (context, item, index) => Padding(
                          padding: EdgeInsets.only(bottom: 0.008 * height),
                          child: ListTile(
                            onTap: () => provider.goToFriendProfile(context,
                                index, item, widget.profile.currentUser),
                            leading: Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor)),
                              child: ProfilePhoto(
                                user: item.friend,
                              ),
                            ),
                            title: AutoSizeText(
                              item.friend.username,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            });
          }),
    );
  }
}
