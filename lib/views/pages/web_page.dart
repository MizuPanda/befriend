import 'package:befriend/providers/web_provider.dart';
import 'package:befriend/views/widgets/befriend_widget.dart';
import 'package:befriend/views/widgets/profile/profile_pictures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utilities/app_localizations.dart';

class WebPage extends StatelessWidget {
  const WebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WebProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const BefriendTitle(),
        ),
        body: Consumer<WebProvider>(builder:
            (BuildContext context, WebProvider provider, Widget? child) {
          return GestureDetector(
            onTap: provider.unfocus,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    focusNode: provider.focusNode,
                    onSubmitted: provider.onSubmitted,
                    onChanged: provider.onChanged,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)
                              ?.translate('wp_search') ??
                          'Search...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ProfilePictures(
                    userID: '',
                    showArchived: false,
                    showOnlyMe: false,
                    isWeb: true,
                    searchTerm: provider.searchTerm,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
