import 'package:befriend/providers/action_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:provider/provider.dart';

import '../../../../models/objects/home.dart';
import '../../../../utilities/app_localizations.dart';

class ActionButton extends StatelessWidget {
  const ActionButton(
      {super.key, required this.home, required this.notifyParent});

  final Home home;
  final Function notifyParent;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (BuildContext context) => ActionProvider(),
        builder: (BuildContext context, Widget? child) {
          return Consumer<ActionProvider>(builder:
              (BuildContext context, ActionProvider provider, Widget? child) {
            final double height = MediaQuery.of(context).size.height;

            return ExpandableFab(
              type: ExpandableFabType.up,
              childrenAnimation: ExpandableFabAnimation.none,
              distance: 0.07 * height,
              openButtonBuilder: RotateFloatingActionButtonBuilder(
                child: const Icon(Icons.menu_rounded),
                fabSize: ExpandableFabSize.regular,
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
              ),
              closeButtonBuilder: DefaultFloatingActionButtonBuilder(
                child: const Icon(Icons.close),
                fabSize: ExpandableFabSize.small,
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
              ),
              children: [
                Row(
                  children: [
                    Text(AppLocalizations.translate(context,
                        key: 'ab_refresh', defaultString: 'Refresh')),
                    const SizedBox(width: 20),
                    FloatingActionButton.small(
                      heroTag: 'refresh_users',
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      onPressed: () => provider.refresh(context),
                      child: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(AppLocalizations.translate(context,
                        key: 'ab_load', defaultString: 'Load more')),
                    const SizedBox(width: 20),
                    FloatingActionButton.small(
                      heroTag: 'load_more',
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      onPressed: () => provider.loadMore(home, notifyParent),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            );
          });
        });
  }
}
