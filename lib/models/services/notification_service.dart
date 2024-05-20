import 'package:befriend/models/data/user_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../../utilities/constants.dart';
import '../data/data_query.dart';
import '../objects/bubble.dart';
import '../objects/friendship.dart';
import '../objects/profile.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static const String _hostIdField = 'hostId';

  static const int newPostID = 0;
  static const int likeID = 1;

  static bool _notificationHandled = false;

  static void _resetNotificationHandled() {
    _notificationHandled = false;
  }

  static void _markNotificationAsHandled() {
    _notificationHandled = true;
  }

  static bool _isNotificationHandled() {
    return _notificationHandled;
  }

  Future<void> initTokenListener(GlobalKey key, Function notify) async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await _messaging.getToken();
        _saveTokenToDatabase(token);
        FirebaseMessaging.instance.onTokenRefresh.listen(_saveTokenToDatabase);
      }

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings darwinInitializationSettings =
          DarwinInitializationSettings();

      const InitializationSettings initializationSettings =
          InitializationSettings(
              android: initializationSettingsAndroid,
              iOS: darwinInitializationSettings);
      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _selectNotification(response, key, notify);
        },
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showNotification(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('(NotificationService): Data= ${message.data}');
        _NotificationType type = message.data.containsKey(_hostIdField)
            ? _NotificationType.newPost
            : _NotificationType.like;

        switch (type) {
          case _NotificationType.newPost:
            String? friendIdPayload = message.data[_hostIdField];
            _navigateToProfile(key, friendIdPayload, notify);
            break;
          case _NotificationType.like:
            _navigateToConnectedProfile(key, notify);
            break;
        }
      });

      FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

      if (key.currentContext!.mounted) {
        _handleInitialMessage(key, notify);
      }
    } catch (e) {
      debugPrint(
          '(NotificationService): Error initializing token listener: $e');
    }
  }

  static Future<void> _selectNotification(
      NotificationResponse response, GlobalKey key, Function notify) async {
    try {
      _NotificationType notificationType = response.id == likeID
          ? _NotificationType.like
          : _NotificationType.newPost;

      switch (notificationType) {
        case _NotificationType.newPost:
          String? friendIdPayload = response.payload;
          if (friendIdPayload != null) {
            _navigateToProfile(key, friendIdPayload, notify);
          }
          break;
        case _NotificationType.like:
          _navigateToConnectedProfile(key, notify);
          break;
      }
    } catch (e) {
      debugPrint('(NotificationService): Error selecting notification: $e');
    }
  }

  static Future<void> _handleInitialMessage(
      GlobalKey key, Function notify) async {
    try {
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage != null) {
        _NotificationType type = initialMessage.data.containsKey(_hostIdField)
            ? _NotificationType.newPost
            : _NotificationType.like;
        switch (type) {
          case _NotificationType.newPost:
            String? friendIdPayload = initialMessage.data[_hostIdField];
            if (key.currentContext!.mounted) {
              _navigateToProfile(key, friendIdPayload, notify);
            }
            break;
          case _NotificationType.like:
            _navigateToConnectedProfile(key, notify);
            break;
        }
      }
    } catch (e) {
      debugPrint('(NotificationService): Error handling initial message: $e');
    }
  }

  static void _navigateToConnectedProfile(
      GlobalKey key, Function notify) async {
    try {
      debugPrint("Navigating to user's profile");
      Bubble connectedUser = await UserManager.getInstance();

      if (key.currentContext!.mounted) {
        GoRouter.of(key.currentContext!).push(
          Constants.profileAddress,
          extra: Profile(
              user: connectedUser,
              currentUser: connectedUser,
              notifyParent: notify,
              friendship: null),
        );
      }
    } catch (e) {
      debugPrint(
          '(NotificationService): Error navigating to connected profile: $e');
    }
  }

  static void _navigateToProfile(
      GlobalKey key, String? friendIdPayload, Function notify) async {
    try {
      if (friendIdPayload != null && friendIdPayload.isNotEmpty) {
        debugPrint("Navigating to profile of $friendIdPayload");
        Bubble connectedUser = await UserManager.getInstance();
        Friendship friendship;

        Friendship? f;

        for (Friendship f1 in connectedUser.friendships) {
          if (f1.friendId() == friendIdPayload) {
            f = f1;
            break;
          }
        }

        if (f == null) {
          friendship =
              await DataQuery.getFriendship(connectedUser.id, friendIdPayload);
        } else {
          friendship = f;
        }

        if (key.currentContext!.mounted) {
          GoRouter.of(key.currentContext!).push(
            Constants.profileAddress,
            extra: Profile(
                user: friendship.friend,
                currentUser: connectedUser,
                notifyParent: notify,
                friendship: friendship),
          );
        }
      }
    } catch (e) {
      debugPrint('(NotificationService): Error navigating to profile: $e');
    }
  }

  static void _showNotification(RemoteMessage message) async {
    _resetNotificationHandled();

    if (_isNotificationHandled()) return;
    _markNotificationAsHandled();

    try {
      Bubble user = await UserManager.getInstance();

      _NotificationType notificationType =
          message.data.containsKey(_hostIdField)
              ? _NotificationType.newPost
              : _NotificationType.like;

      String? payload;
      int id;
      Importance importance;
      Priority priority;

      switch (notificationType) {
        case _NotificationType.newPost:
          if (!user.postNotificationOn) {
            return;
          }
          payload = message.data[_hostIdField];
          id = newPostID;
          importance = Importance.defaultImportance;
          priority = Priority.defaultPriority;
          break;
        case _NotificationType.like:
          if (!user.likeNotificationOn) {
            return;
          }
          id = likeID;
          importance = Importance.low;
          priority = Priority.low;
          break;
      }

      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('befriend_id', 'befriend_name',
              channelDescription: 'befriend',
              importance: importance,
              priority: priority,
              showWhen: false);
      const DarwinNotificationDetails darwinNotificationDetails =
          DarwinNotificationDetails();

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: darwinNotificationDetails);

      await _localNotifications.show(
          id, // ID
          message.notification?.title, // Title
          message.notification?.body, // Body
          platformChannelSpecifics,
          payload: payload); // Pass the hostId as payload
    } catch (e) {
      debugPrint('(NotificationService): Error showing notification: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    //debugPrint("Handling a background message: ${message.messageId}");
    debugPrint('(NotificationService): $message');

    _showNotification(message);
  }

  static void _saveTokenToDatabase(String? token) {
    // Save the token for this user in Firestore
    try {
      DataQuery.updateDocument(Constants.notificationToken, token);
    } catch (e) {
      debugPrint('(NotificationService): Error saving token to database: $e');
    }
  }
}

enum _NotificationType {
  newPost,
  like,
}
