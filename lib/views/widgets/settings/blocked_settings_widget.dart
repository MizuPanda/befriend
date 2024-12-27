import 'package:befriend/providers/blocked_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../../models/objects/bubble.dart';
import '../../../utilities/app_localizations.dart';

class BlockedSettingsWidget extends StatefulWidget {
  const BlockedSettingsWidget({
    super.key,
  });

  @override
  State<BlockedSettingsWidget> createState() => _BlockedSettingsWidgetState();
}

class _BlockedSettingsWidgetState extends State<BlockedSettingsWidget> {
  final BlockedSettingsProvider _provider = BlockedSettingsProvider();

  @override
  void initState() {
    _provider.initWidgetState();
    super.initState();
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
      child: Consumer<BlockedSettingsProvider>(builder: (BuildContext context,
          BlockedSettingsProvider provider, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text(
                  AppLocalizations.of(context)?.translate('bsw_blocked') ??
                      "Blocked accounts ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.supervisor_account_rounded)
              ],
            ),
          ),
          body: PagedListView<int, Bubble>(
            pagingController: provider.pagingController,
            builderDelegate: PagedChildBuilderDelegate<Bubble>(
              itemBuilder: (context, user, index) => ListTile(
                leading: CircleAvatar(backgroundImage: user.avatar),
                title: Text(
                  user.username,
                  style: GoogleFonts.openSans(),
                ),
                trailing: TextButton(
                    onPressed: () => provider.unblockUser(user, context),
                    child: Text(AppLocalizations.of(context)
                            ?.translate('bsw_unblock') ??
                        'Unblock')),
              ),
              firstPageProgressIndicatorBuilder: (context) =>
                  const Center(child: CircularProgressIndicator()),
              newPageProgressIndicatorBuilder: (context) =>
                  const Center(child: CircularProgressIndicator()),
              noItemsFoundIndicatorBuilder: (context) => Center(
                child: Text(
                  AppLocalizations.of(context)?.translate('bsw_none') ??
                      'No users blocked',
                  style: GoogleFonts.openSans(fontSize: 16),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
