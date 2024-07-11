import 'package:befriend/models/data/data_query.dart';
import 'package:befriend/models/data/user_manager.dart';
import 'package:befriend/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

import '../../../models/objects/bubble.dart';
import '../../../utilities/app_localizations.dart';

class NotificationsSettingsWidget extends StatefulWidget {
  const NotificationsSettingsWidget({super.key});

  @override
  State<NotificationsSettingsWidget> createState() =>
      _NotificationsSettingsWidgetState();
}

class _NotificationsSettingsWidgetState
    extends State<NotificationsSettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.translate('nsw_notifications') ??
              'Notifications',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
            future: UserManager.getInstance(),
            builder: (
              BuildContext context,
              AsyncSnapshot<Bubble> asyncData,
            ) {
              if (!asyncData.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              Bubble? user = asyncData.data;
              return SettingsList(
                sections: [
                  SettingsSection(
                    tiles: [
                      SettingsTile.switchTile(
                        onPressed: null,
                        onToggle: (value) async {
                          try {
                            await DataQuery.updateDocument(
                                Constants.postNotificationOnDoc, value);
                            setState(() {
                              UserManager.setPostNotification(value);
                            });
                          } catch (e) {
                            debugPrint(
                                '(NotificationsSettingsWidget) Error changing post notification toggle: $e');
                          }
                        },
                        initialValue: user?.postNotificationOn,
                        leading: const Icon(
                          Icons.notifications_rounded,
                          color: Colors.grey,
                        ),
                        title: Text(AppLocalizations.of(context)
                                ?.translate('nsw_post') ??
                            'New post notification'),
                        description: Text(AppLocalizations.of(context)
                                ?.translate('nsw_post_description') ??
                            'X has posted a new picture. Check it out!'),
                      ),
                      SettingsTile.switchTile(
                        onToggle: (value) async {
                          try {
                            await DataQuery.updateDocument(
                                Constants.likeNotificationOnDoc, value);
                            setState(() {
                              UserManager.setLikeNotification(value);
                            });
                          } catch (e) {
                            debugPrint(
                                '(NotificationsSettingsWidget) Error changing post notification toggle: $e');
                          }
                        },
                        leading: const Icon(
                          Icons.notifications_rounded,
                          color: Colors.grey,
                        ),
                        initialValue: user?.likeNotificationOn,
                        title: Text(AppLocalizations.of(context)
                                ?.translate('nsw_like') ??
                            'New like notification'),
                        description: Text(AppLocalizations.of(context)
                                ?.translate('nsw_like_description') ??
                            'X has liked your post!'),
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
