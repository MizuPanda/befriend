import 'package:befriend/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:provider/provider.dart';

import '../../providers/material_provider.dart';
import '../../utilities/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.translate(context,
              key: 'sp_settings', defaultString: 'Settings'),
          style: const TextStyle(fontWeight: FontWeight.bold),
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
                        title: Text(
                          AppLocalizations.translate(context,
                              key: 'sp_data', defaultString: 'Your Data'),
                        ),
                        tiles: [
                          SettingsTile.navigation(
                            leading: Icon(lightMode
                                ? Icons.archive_rounded
                                : Icons.archive_outlined),
                            title: Text(
                              AppLocalizations.translate(context,
                                  key: 'sp_archived',
                                  defaultString: 'Archived pictures'),
                            ),
                            onPressed: provider.goToArchiveSettings,
                          ),
                          SettingsTile.navigation(
                            leading: Icon(lightMode
                                ? Icons.block_rounded
                                : Icons.block_outlined),
                            title: Text(
                              AppLocalizations.translate(context,
                                  key: 'sp_blocked',
                                  defaultString: 'Blocked accounts'),
                            ),
                            onPressed: provider.goToBlockedSettings,
                          ),
                          SettingsTile(
                            leading: Icon(lightMode
                                ? Icons.refresh_rounded
                                : Icons.refresh_outlined),
                            title: Text(
                              AppLocalizations.translate(context,
                                  key: 'sp_refresh',
                                  defaultString: 'Refresh home page'),
                            ),
                            onPressed: provider.refreshHomePage,
                          ),
                        ],
                      ),
                      SettingsSection(
                        title: Text(
                          AppLocalizations.translate(context,
                              key: 'sp_pc',
                              defaultString: 'Privacy and confidentiality'),
                        ),
                        tiles: [
                          SettingsTile(
                            leading: Icon(lightMode
                                ? Icons.privacy_tip_rounded
                                : Icons.privacy_tip_outlined),
                            title: Text(
                              AppLocalizations.translate(context,
                                  key: 'sp_policy',
                                  defaultString: 'Privacy Policy'),
                            ),
                            onPressed: provider.openPrivacyPolicy,
                          ),
                          SettingsTile.navigation(
                            leading: Icon(lightMode
                                ? Icons.lock_rounded
                                : Icons.lock_outline_rounded),
                            title: Text(
                              AppLocalizations.translate(context,
                                  key: 'sp_consent',
                                  defaultString: 'Manage consent'),
                            ),
                            description: Text(AppLocalizations.translate(
                                context,
                                key: 'sp_preferences',
                                defaultString:
                                    'Ads preferences, account deletion')),
                            onPressed: provider.goToConsentSettings,
                          ),
                          SettingsTile.navigation(
                            leading: Icon(lightMode
                                ? Icons.notifications_rounded
                                : Icons.notifications_outlined),
                            title: Text(
                              AppLocalizations.translate(context,
                                  key: 'sp_notifications',
                                  defaultString: 'Notifications'),
                            ),
                            onPressed: provider.goToNotificationsSettings,
                          ),
                        ],
                      ),
                      SettingsSection(
                        title: Text(
                          AppLocalizations.translate(context,
                              key: 'sp_appearance',
                              defaultString: 'Appearance'),
                        ),
                        tiles: [
                          SettingsTile(
                            leading: Icon(lightMode
                                ? Icons.dark_mode_rounded
                                : Icons.dark_mode_outlined),
                            title: Text(
                              AppLocalizations.translate(context,
                                  key: 'sp_theme', defaultString: 'Theme'),
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
                                    Text(materialProvider.themeText(context)),
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
                                  PopupMenuItem(
                                      value: ThemeMode.light,
                                      child: Text(AppLocalizations.translate(
                                          context,
                                          key: 'sp_light',
                                          defaultString: 'Light'))),
                                  PopupMenuItem(
                                      value: ThemeMode.dark,
                                      child: Text(AppLocalizations.translate(
                                          context,
                                          key: 'sp_dark',
                                          defaultString: 'Dark'))),
                                  PopupMenuItem(
                                      value: ThemeMode.system,
                                      child: Text(AppLocalizations.translate(
                                          context,
                                          key: 'sp_default',
                                          defaultString: 'System Default'))),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                      SettingsSection(
                        title: Text(
                          AppLocalizations.translate(context,
                              key: 'sp_misc', defaultString: 'Misc'),
                        ),
                        tiles: [
                          SettingsTile(
                            leading: Icon(lightMode
                                ? Icons.description_rounded
                                : Icons.description_outlined),
                            title: Text(
                              AppLocalizations.translate(context,
                                  key: 'sp_terms',
                                  defaultString: 'Terms and Conditions'),
                            ),
                            onPressed: provider.openTermsAndConditions,
                          ),
                        ],
                      ),
                      SettingsSection(
                        title: Text(
                          AppLocalizations.translate(context,
                              key: 'sp_help', defaultString: 'Help'),
                        ),
                        tiles: [
                          SettingsTile(
                            leading: Icon(lightMode
                                ? Icons.help_rounded
                                : Icons.help_outline_rounded),
                            title: Text(
                              AppLocalizations.translate(context,
                                  key: 'sp_how',
                                  defaultString: 'How to use Befriend'),
                            ),
                            onPressed: provider.openTutorial,
                          ),
                          SettingsTile(
                            leading: Icon(lightMode
                                ? Icons.contact_support_rounded
                                : Icons.contact_support_outlined),
                            title: Text(
                              AppLocalizations.translate(context,
                                  key: 'sp_contact', defaultString: 'Contact'),
                            ),
                            onPressed: provider.openContact,
                          ),
                        ],
                      ),
                      SettingsSection(
                        title: Text(
                          AppLocalizations.translate(context,
                              key: 'sp_login', defaultString: 'Login'),
                        ),
                        tiles: [
                          SettingsTile(
                            title: Text(
                              AppLocalizations.translate(context,
                                  key: 'sp_logout', defaultString: 'Log out'),
                              style: const TextStyle(color: Colors.red),
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
