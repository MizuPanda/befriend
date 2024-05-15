import 'package:befriend/models/authentication/consent_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

import '../../../providers/settings_provider.dart';

class ConsentSettingsWidget extends StatelessWidget {
  const ConsentSettingsWidget({super.key, required this.provider});

  final SettingsProvider provider;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage consent',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                          title: const Text(
                            'Ads preferences',
                          ),
                          onPressed: (_) => provider.reloadConsentForm,
                        ),
                      SettingsTile(
                        leading: const Icon(
                          Icons.delete_forever_outlined,
                          color: Colors.red,
                        ),
                        title: const Text(
                          'Delete your account',
                          style: TextStyle(color: Colors.red),
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
