import 'package:auto_size_text/auto_size_text.dart';
import 'package:befriend/models/objects/bubble.dart';
import 'package:befriend/providers/mutual_provider.dart';
import 'package:befriend/views/widgets/users/profile_photo.dart';
import 'package:flutter/material.dart';
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
        commonFriends: widget.profile.commonFriends,
        userId: widget.profile.currentUser.id,
        hasNonLoadedFriends: widget.profile.currentUser.hasNonLoadedFriends(),
        getLastFriendshipDocument:
            widget.profile.currentUser.getLastFriendshipDocument());
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title:  Text(AppLocalizations.of(context)?.translate('mp_friends')??'Mutual friends'),
      ),
      body: ChangeNotifierProvider.value(
          value: _provider,
          builder: (BuildContext context, Widget? child) {
            return Consumer(builder:
                (BuildContext context, MutualProvider provider, Widget? child) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(width * 0.03),
                    child: TextField(
                      onChanged: provider.filterUsers,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)?.translate('general_word_search')??'Search',
                        suffixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: provider.isSearching
                        ? ListView.builder(
                            itemCount: provider.length(),
                            itemBuilder: (context, index) {
                              final user = provider.user(index);
                              return Padding(
                                padding:
                                    EdgeInsets.only(bottom: 0.008 * height),
                                child: ListTile(
                                  leading: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .primaryColor)),
                                    child: ProfilePhoto(
                                      user: user,
                                    ),
                                  ),
                                  title: AutoSizeText(
                                    user.username,
                                    maxLines: 1,
                                  ),
                                ),
                              );
                            },
                          )
                        : PagedListView<int, Bubble>(
                            pagingController: provider.pagingController,
                            builderDelegate: PagedChildBuilderDelegate<Bubble>(
                              itemBuilder: (context, item, index) => Padding(
                                padding:
                                    EdgeInsets.only(bottom: 0.008 * height),
                                child: ListTile(
                                  leading: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .primaryColor)),
                                    child: ProfilePhoto(
                                      user: item,
                                    ),
                                  ),
                                  title: AutoSizeText(
                                    item.username,
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
