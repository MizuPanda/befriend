import 'package:befriend/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:provider/provider.dart';

import '../../providers/material_provider.dart';

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
            create: (_) => SettingsProvider(),
            builder: (BuildContext context, Widget? child) {
              return Consumer<SettingsProvider>(builder: (BuildContext context,
                  SettingsProvider provider, Widget? child) {
                return Consumer<MaterialProvider>(builder:
                    (BuildContext context, MaterialProvider materialProvider,
                        Widget? child) {
                  final bool lightMode = materialProvider.isLightMode(context);

                  return SettingsList(
                    lightTheme: SettingsThemeData(
                        titleTextColor: ThemeData().primaryColor),
                    sections: [
                      SettingsSection(
                        title: const Text(
                          'Your Data',
                        ),
                        tiles: [
                          SettingsTile.navigation(
                            leading: Icon(lightMode
                                ? Icons.archive_rounded
                                : Icons.archive_outlined),
                            title: const Text(
                              'Archived pictures',
                            ),
                            onPressed: provider.goToArchiveSettings,
                          ),
                          SettingsTile.navigation(
                            leading: Icon(lightMode
                                ? Icons.block_rounded
                                : Icons.block_outlined),
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
                            leading: Icon(lightMode
                                ? Icons.privacy_tip_rounded
                                : Icons.privacy_tip_outlined),
                            title: const Text(
                              'Privacy Policy',
                            ),
                            onPressed: provider.openPrivacyPolicy,
                          ),
                          SettingsTile.navigation(
                            leading: Icon(lightMode
                                ? Icons.lock_rounded
                                : Icons.lock_outline_rounded),
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
                          SettingsTile(
                            leading: Icon(lightMode
                                ? Icons.dark_mode_rounded
                                : Icons.dark_mode_outlined),
                            title: const Text(
                              'Theme',
                            ),
                            trailing: Consumer(builder: (BuildContext context,
                                MaterialProvider materialProvider,
                                Widget? child) {
                              return PopupMenuButton<ThemeMode>(
                                icon: Row(
                                  children: [
                                    Icon(materialProvider.themeIconData()),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(materialProvider.themeText()),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_right,
                                      color: Colors.grey,
                                    )
                                  ],
                                ),
                                onSelected: (ThemeMode mode) async {
                                  await materialProvider.onSelected(mode);
                                },
                                itemBuilder: (BuildContext context) => [
                                  const PopupMenuItem(
                                      value: ThemeMode.light,
                                      child: Text('Light')),
                                  const PopupMenuItem(
                                      value: ThemeMode.dark,
                                      child: Text('Dark')),
                                  const PopupMenuItem(
                                      value: ThemeMode.system,
                                      child: Text('System Default')),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                      SettingsSection(
                        title: const Text(
                          'Misc',
                        ),
                        tiles: [
                          SettingsTile(
                            leading: Icon(lightMode
                                ? Icons.description_rounded
                                : Icons.description_outlined),
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
                            leading: Icon(lightMode
                                ? Icons.help_rounded
                                : Icons.help_outline_rounded),
                            title: const Text(
                              'How to use Befriend',
                            ),
                            onPressed: provider.openTutorial,
                          ),
                          SettingsTile(
                            leading: Icon(lightMode
                                ? Icons.contact_support_rounded
                                : Icons.contact_support_outlined),
                            title: const Text(
                              'Contact',
                            ),
                            onPressed: provider.openContact,
                          ),
                        ],
                      ),
                      SettingsSection(
                        title: const Text(
                          'Login',
                        ),
                        tiles: [
                          SettingsTile(
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
              });
            }),
      ),
    );
  }
}
