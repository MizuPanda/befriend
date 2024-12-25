// search_page.dart

import 'package:befriend/models/objects/search_history.dart';
import 'package:befriend/providers/wide_search_provider.dart';
import 'package:befriend/views/widgets/shimmers/search_history_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../models/objects/bubble.dart';

class WideSearchPage extends StatefulWidget {
  const WideSearchPage({super.key});

  @override
  State<WideSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<WideSearchPage> {
  final WideSearchProvider _provider = WideSearchProvider();

  static const int _firstShimmerCount = 10;
  static const int _reloadShimmerCount = 3;

  @override
  void initState() {
    super.initState();
    _provider.initWidgetState();
  }

  @override
  void dispose() {
    _provider.disposeWidgetState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: _provider,
        builder: (BuildContext context, Widget? child) {
          return Consumer<WideSearchProvider>(builder: (BuildContext context,
              WideSearchProvider provider, Widget? child) {
            return Scaffold(
              appBar: AppBar(
                title: TextField(
                  focusNode: provider.focusNode,
                  controller: provider.searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by username',
                    hintStyle: TextStyle(
                        color: provider.hasFocus()
                            ? Theme.of(context).colorScheme.primary
                            : null),
                    prefixIcon: Icon(
                      Icons.search,
                      color: provider.hasFocus()
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  onChanged: provider.onSearchChanged,
                ),
                actions: [
                  IconButton(
                      onPressed: () => provider.openEraseHistoryDialog(context),
                      icon: const Icon(Icons.manage_history_rounded)),
                ],
              ),
              body: provider.showHistory
                  ? PagedListView<DocumentSnapshot?, SearchHistory>(
                      pagingController: provider.historyPagingController,
                      builderDelegate: PagedChildBuilderDelegate<SearchHistory>(
                          itemBuilder: (context, user, index) => ListTile(
                                leading:
                                    CircleAvatar(backgroundImage: user.avatar),
                                title: Text(user.username),
                                onTap: () => provider.goToFriendProfile(
                                    context, user.bubble),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () =>
                                      provider.deleteHistoryEntry(user),
                                ),
                              ),
                          firstPageProgressIndicatorBuilder:
                              (BuildContext context) {
                            return const SearchHistoryShimmer(
                                hasTrailing: true,
                                itemCount: _firstShimmerCount);
                          },
                          newPageProgressIndicatorBuilder:
                              (BuildContext context) {
                            return const SearchHistoryShimmer(
                                hasTrailing: true,
                                itemCount: _reloadShimmerCount);
                          },
                          noItemsFoundIndicatorBuilder: (context) {
                            return const Center();
                          }),
                    )
                  : PagedListView<DocumentSnapshot?, Bubble>(
                      pagingController: provider.pagingController,
                      builderDelegate: PagedChildBuilderDelegate<Bubble>(
                          itemBuilder: (context, user, index) => ListTile(
                                leading:
                                    CircleAvatar(backgroundImage: user.avatar),
                                title: Text(user.username),
                                onTap: () => provider.onTap(context, user),
                              ),
                          firstPageProgressIndicatorBuilder:
                              (BuildContext context) {
                            return const SearchHistoryShimmer(
                                hasTrailing: false,
                                itemCount: _firstShimmerCount);
                          },
                          newPageProgressIndicatorBuilder:
                              (BuildContext context) {
                            return const SearchHistoryShimmer(
                                hasTrailing: false,
                                itemCount: _reloadShimmerCount);
                          },
                          noItemsFoundIndicatorBuilder: (context) {
                            return const Center();
                          }),
                    ),
            );
          });
        });
  }
}
