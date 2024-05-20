import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/picture_card_provider.dart';

class MoreButton extends StatelessWidget {
  final Iterable<dynamic> usernames;

  const MoreButton({
    Key? key,
    required this.usernames,
  }) : super(key: key);

  static const double _iconTextDistanceWidthMultiplier = 16 / 448;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Consumer(builder:
        (BuildContext context, PictureCardProvider provider, Widget? child) {
      return PopupMenuButton<PopSelection>(
        icon: Icon(
          Icons.more_vert,
          color: Colors.grey.withOpacity(0.9),
        ),
        itemBuilder: (BuildContext context) => [
          if (provider.isUsersProfile)
            PopupMenuItem<PopSelection>(
              value: PopSelection.archive,
              child: Row(
                children: [
                  const Icon(
                    Icons.archive_outlined,
                  ), // Archive icon
                  SizedBox(width: _iconTextDistanceWidthMultiplier * width),
                  Text(provider.isArchived() ? 'Restore' : 'Archive'),
                  SizedBox(width: _iconTextDistanceWidthMultiplier * width * 2),
                ],
              ),
            ),
          if (provider.isPictureHost())
            PopupMenuItem<PopSelection>(
              value: PopSelection.delete,
              child: Row(
                children: [
                  const Icon(Icons.delete_outline_rounded,
                      color: Colors.red), // Archive icon
                  SizedBox(width: _iconTextDistanceWidthMultiplier * width),
                  const Text('Delete', style: TextStyle(color: Colors.red)),
                  SizedBox(width: _iconTextDistanceWidthMultiplier * width * 2),
                ],
              ),
            ),
          if (!provider.isPictureHost())
            PopupMenuItem<PopSelection>(
              value: PopSelection.report,
              child: Row(
                children: [
                  const Icon(
                    Icons.report_outlined,
                  ),
                  SizedBox(width: _iconTextDistanceWidthMultiplier * width),
                  const Text(
                    'Report',
                  ),
                  SizedBox(width: _iconTextDistanceWidthMultiplier * width * 2),
                ],
              ),
            ),
          PopupMenuItem<PopSelection>(
            value: PopSelection.info,
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                ), // Info icon
                SizedBox(width: _iconTextDistanceWidthMultiplier * width),
                const Text('Info'),
                SizedBox(width: _iconTextDistanceWidthMultiplier * width * 2),
              ],
            ),
          ),
        ],
        onSelected: (PopSelection value) async {
          await provider.onSelectPop(value, context, usernames);
        },
      );
    });
  }
}

enum PopSelection { archive, delete, report, info }
