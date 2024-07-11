import 'package:befriend/models/authentication/consent_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

import '../../../providers/settings_provider.dart';
import '../../../utilities/app_localizations.dart';

class ConsentSettingsWidget extends StatelessWidget {
  const ConsentSettingsWidget({super.key, required this.provider});

  final SettingsProvider provider;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.translate('csw_manage') ??
              'Manage consent',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
            future: ConsentManager.isGDRP(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return SettingsList(
                sections: [
                  SettingsSection(
                    tiles: [
                      if (snapshot.data!)
                        SettingsTile(
                          leading: const Icon(Icons.ads_click),
                          title: Text(
                            AppLocalizations.of(context)
                                    ?.translate('csw_ads') ??
                                'Ads preferences',
                          ),
                          onPressed: provider.reloadConsentForm,
                        ),
                      SettingsTile(
                        leading: const Icon(
                          Icons.delete_forever_outlined,
                          color: Colors.red,
                        ),
                        title: Text(
                          AppLocalizations.of(context)
                                  ?.translate('csw_delete') ??
                              'Delete your account',
                          style: const TextStyle(color: Colors.red),
                        ),
                        onPressed: (BuildContext context) async {
                          await provider.showDeleteAccountConfirmation(context);
                        },
                      ),
                    ],
                  ),
                ],
              );
            }),
      ),
    );
  }
}
