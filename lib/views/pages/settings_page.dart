import 'package:befriend/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ChangeNotifierProvider(
            create: (BuildContext context) => SettingsProvider(),
            builder: (BuildContext context, Widget? child) {
              return Consumer<SettingsProvider>(builder: (BuildContext context,
                  SettingsProvider provider, Widget? child) {
                return SettingsList(
                  lightTheme: SettingsThemeData(
                      titleTextColor: ThemeData().primaryColor),
                  sections: [
                    SettingsSection(
                      title: const Text(
                        'Your Data',
                      ),
                      tiles: [
                        SettingsTile(
                          leading: const Icon(Icons.archive_outlined),
                          title: const Text(
                            'Archived pictures',
                          ),
                          onPressed: provider.goToArchiveSettings,
                        ),
                        SettingsTile(
                          leading: const Icon(Icons.block_rounded),
                          title: const Text(
                            'Blocked accounts',
                          ),
                          onPressed: provider.goToBlockedSettings,
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: const Text(
                        'Privacy and confidentiality',
                      ),
                      tiles: [
                        SettingsTile(
                          leading: const Icon(Icons.privacy_tip_rounded),
                          title: const Text(
                            'Privacy Policy',
                          ),
                          onPressed: provider.openPrivacyPolicy,
                        ),
                        SettingsTile(
                          leading: const Icon(Icons.lock_open),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                          ),
                          title: const Text(
                            'Manage consent',
                          ),
                          description:
                              const Text('Ads preferences, account deletion'),
                          onPressed: provider.goToConsentSettings,
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: const Text(
                        'Appearance',
                      ),
                      tiles: [
                        SettingsTile.switchTile(
                          leading: const Icon(Icons.dark_mode),
                          title: const Text(
                            'Dark Mode',
                          ),
                          initialValue: null,
                          onToggle: (bool value) {},
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: const Text(
                        'Misc',
                      ),
                      tiles: [
                        SettingsTile(
                          leading: const Icon(Icons.description),
                          title: const Text(
                            'Terms and Conditions',
                          ),
                          onPressed: provider.openTermsAndConditions,
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: const Text(
                        'Help',
                      ),
                      tiles: [
                        SettingsTile(
                          leading: const Icon(Icons.help_outline_rounded),
                          title: const Text(
                            'How to use Befriend',
                          ),
                          onPressed: provider.openTutorial,
                        ),
                        SettingsTile(
                          leading: const Icon(Icons.contact_support_outlined),
                          title: const Text(
                            'Contact',
                          ),
                          onPressed: provider.openTutorial,
                        ),
                      ],
                    ),
                    SettingsSection(
                      title: const Text(
                        'Login',
                      ),
                      tiles: [
                        SettingsTile.navigation(
                          title: const Text(
                            'Log out',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: provider.signOut,
                        ),
                      ],
                    ),
                  ],
                );
              });
            }),
      ),
    );
  }
}
