import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:befriend/providers/home_provider.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/app_localizations.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    final double friendPadding = 0.177 * width;

    return Consumer<HomeProvider>(
        builder: (BuildContext context, HomeProvider provider, Widget? child) {
      return Container(
        alignment: Alignment.bottomRight,
        padding: EdgeInsets.only(
            bottom: 0.060 * height,
            right: Constants.homeHorizontalPaddingMultiplier * width),
        child: AnimSearchBar(
          helpText:
              AppLocalizations.of(context)?.translate('sb_text') ?? "Search...",
          rtl: true,
          width: MediaQuery.of(context).size.width - friendPadding,
          onSuffixTap: provider.clearSearch,
          textController: provider.searchEditingController,
          onSubmitted: (String username) {
            provider.search(username, context);
          },
        ),
      );
    });
  }
}
