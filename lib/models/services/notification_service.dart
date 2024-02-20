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

  Future<void> initTokenListener(GlobalKey key, Function notify) async {
    // Request user permission for push notifications
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get the token each time the application loads
      String? token = await _messaging.getToken();
      // Save the initial token to the database
      saveTokenToDatabase(token);

      // Any time the token refreshes, store this in the database too.
      FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
    }

    // Initialize flutter_local_notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _selectNotification(response, key, notify);
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // Handle background notification clicks
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('(NotificationService): Data= ${message.data}');

      _NotificationType type = message.data.containsKey(_hostIdField)
          ? _NotificationType.newPost
          : _NotificationType.like;

      switch (type) {
        case _NotificationType.newPost:
          String? friendIdPayload = message.data[_hostIdField];
          // Assuming you have access to context and notify here, or manage to pass them
          _navigateToProfile(key, friendIdPayload, notify);
          break;
        case _NotificationType.like:
          _navigateToConnectedProfile(key, notify);
          break;
      }
    });

    // Setup a background message handler
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Handle initial message
    if (key.currentContext!.mounted) {
      handleInitialMessage(key, notify);
    }
  }

  static Future<void> _selectNotification(
      NotificationResponse response, GlobalKey key, Function notify) async {
    _NotificationType notificationType = response.id == likeID
        ? _NotificationType.like
        : _NotificationType.newPost;

    switch (notificationType) {
      case _NotificationType.newPost:
        String? friendIdPayload = response.payload;
        if (friendIdPayload != null) {
          // Handle navigation to the profile page using payload (hostId)
          // This assumes you have a navigator key or some other means of navigating without context
          _navigateToProfile(key, friendIdPayload, notify);
        }
        break;
      case _NotificationType.like:
        _navigateToConnectedProfile(key, notify);
        break;
    }
  }

  static Future<void> handleInitialMessage(
      GlobalKey key, Function notify) async {
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
  }

  static void _navigateToConnectedProfile(
      GlobalKey key, Function notify) async {
    // Example: Fetch necessary data and navigate
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
  }

  static void _navigateToProfile(
      GlobalKey key, String? friendIdPayload, Function notify) async {
    if (friendIdPayload != null && friendIdPayload.isNotEmpty) {
      // Example: Fetch necessary data and navigate
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
  }

  static void _showNotification(RemoteMessage message) async {
    _NotificationType notificationType = message.data.containsKey(_hostIdField)
        ? _NotificationType.newPost
        : _NotificationType.like;

    String? payload;
    int id;
    Importance importance;
    Priority priority;

    switch (notificationType) {
      case _NotificationType.newPost:
        payload = message.data[_hostIdField];
        id = newPostID;
        importance = Importance.defaultImportance;
        priority = Priority.defaultPriority;
        break;
      case _NotificationType.like:
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
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
        id, // ID
        message.notification?.title, // Title
        message.notification?.body, // Body
        platformChannelSpecifics,
        payload: payload); // Pass the hostId as payload
  }

  @pragma('vm:entry-point')
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    //debugPrint("Handling a background message: ${message.messageId}");
    debugPrint('(NotificationService): $message');
    _showNotification(message);
  }

  static void saveTokenToDatabase(String? token) {
    // Save the token for this user in Firestore
    DataQuery.updateDocument(Constants.notificationToken, token);
  }
}

enum _NotificationType {
  newPost,
  like,
}
