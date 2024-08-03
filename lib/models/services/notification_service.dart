import 'dart:io';

import 'package:befriend/models/data/user_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../../utilities/constants.dart';
import '../data/data_query.dart';
import '../objects/bubble.dart';
import '../objects/friendship.dart';
import '../objects/profile.dart';

class NotificationService {
  static GlobalKey key = GlobalKey();
  static Function notify = () {};

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static const String _hostIdField = 'hostId';

  static const int _newPostID = 0;
  static const int _newLikeID = 1;

  static Future<void> initNotifications(
      GlobalKey globalKey, Function notifyParent) async {
    try {
      key = globalKey;
      notify = notifyParent;

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

      await _initLocalNotifications();

      FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationMessage(
          message,
        );
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          _showNotification(message);
        }
      });

      _handleInitialMessage();
    } catch (e) {
      debugPrint('(NotificationService) Error initializing token listener: $e');
    }
  }

  static Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/notification_icon');

    final DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: (id, title, body, payload) {});

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: darwinInitializationSettings,
    );

    if (Platform.isAndroid) {
      _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!
          .requestNotificationsPermission();
    }

    _localNotifications.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse: _onNotificationTap,
        onDidReceiveNotificationResponse: _onNotificationTap);
  }

  static Future<void> _onNotificationTap(
    NotificationResponse response,
  ) async {
    _handleNotificationResponse(
      response,
    );
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    try {
      _NotificationType notificationType = _getTypeFromMessage(message);

      String? payload;
      int id;
      Importance importance;
      Priority priority;

      switch (notificationType) {
        case _NotificationType.newPost:
          payload = message.data[_hostIdField];
          id = _newPostID;
          importance = Importance.defaultImportance;
          priority = Priority.defaultPriority;
          break;
        case _NotificationType.like:
          id = _newLikeID;
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

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await _localNotifications.show(
          id, // ID
          message.notification?.title, // Title
          message.notification?.body, // Body
          platformChannelSpecifics,
          payload: payload); // Pass the hostId as payload
      debugPrint('(NotificationService) Showing foreground notification');
    } catch (e) {
      debugPrint('(NotificationService) Error showing notification: $e');
    }
  }

  static Future<void> _handleNotificationData(
    _NotificationType type,
    String? payload,
  ) async {
    try {
      switch (type) {
        case _NotificationType.newPost:
          if (payload != null) {
            _navigateToProfile(
              payload,
            );
          }
          break;
        case _NotificationType.like:
          _navigateToConnectedProfile();
          break;
      }
    } catch (e) {
      debugPrint('(NotificationService): Error selecting notification: $e');
    }
  }

  static Future<void> _handleNotificationResponse(
    NotificationResponse response,
  ) async {
    _NotificationType type = _getTypeFromID(response);
    _handleNotificationData(
      type,
      response.payload,
    );
  }

  static Future<void> _handleNotificationMessage(
    RemoteMessage message,
  ) async {
    _NotificationType type = _getTypeFromMessage(message);
    String? payload = message.data.containsKey(_hostIdField)
        ? message.data[_hostIdField]
        : null;

    _handleNotificationData(
      type,
      payload,
    );
  }

  static Future<void> _handleInitialMessage() async {
    try {
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage != null) {
        debugPrint("(NotificationService) Launched from a terminated state");
        await Future.delayed(const Duration(seconds: 1));
        _handleNotificationMessage(
          initialMessage,
        );
      }
    } catch (e) {
      debugPrint('(NotificationService): Error handling initial message: $e');
    }
  }

  static Future<void> _navigateToConnectedProfile() async {
    try {
      debugPrint("(NotificationService) Navigating to user's profile");
      Bubble connectedUser = await UserManager.getInstance();

      if (key.currentContext!.mounted) {
        GoRouter.of(key.currentContext!).push(
          Constants.profileAddress,
          extra: Profile(
            user: connectedUser,
            currentUser: connectedUser,
            notifyParent: notify,
            friendship: null,
            isLocked: false,
          ),
        );
      }
    } catch (e) {
      debugPrint(
          '(NotificationService) Error navigating to connected profile: $e');
    }
  }

  static Future<void> _navigateToProfile(
    String? friendIdPayload,
  ) async {
    try {
      if (friendIdPayload != null && friendIdPayload.isNotEmpty) {
        debugPrint(
            "(NotificationService) Navigating to profile of $friendIdPayload");
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
              friendship: friendship,
              isLocked: false,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('(NotificationService) Error navigating to profile: $e');
    }
  }

  static _NotificationType _getTypeFromMessage(RemoteMessage message) {
    return message.data.containsKey(_hostIdField)
        ? _NotificationType.newPost
        : _NotificationType.like;
  }

  static _NotificationType _getTypeFromID(NotificationResponse response) {
    switch (response.id) {
      case _newPostID:
        return _NotificationType.newPost;
      case _newLikeID:
        return _NotificationType.like;
      default:
        return _NotificationType.like;
    }
  }

  static Future<void> _saveTokenToDatabase(String? token) async {
    // Save the token for this user in Firestore
    try {
      await DataQuery.updateDocument(Constants.notificationToken, token);
    } catch (e) {
      debugPrint('(NotificationService) Error saving token to database: $e');
    }
  }
}

Future<void> backgroundMessageHandler(RemoteMessage message) async {
  debugPrint(
      "(NotificationService) A new notification has been detected in the background");
}

enum _NotificationType {
  newPost,
  like,
}
