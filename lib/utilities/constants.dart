import 'package:befriend/router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Constants {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String appID = 'befriend';
  //USERS
  static const String usernameDoc = 'username';
  static const String notificationToken = 'notificationToken';
  static const String avatarDoc = 'avatar';
  static const String counterDoc = 'counter';
  static const String friendsDoc = 'friends';
  static const String powerDoc = 'power';
  static const String birthYearDoc = 'birthYear';
  static const String hostingDoc = 'hosting';
  static const String sliderDoc = 'sliderValue';
  static const String hostingFriendshipsDoc = 'hostingFriendships';
  static const String lastSeenUsersMapDoc = 'lastSeenUsersMap';
  static const String blockedUsersDoc = 'blocked';
  static const String postNotificationOnDoc = 'postNotificationOn';
  static const String likeNotificationOnDoc = 'likeNotificationOn';
  //FRIENDSHIPS
  static const String progressDoc = 'progress';
  static const String levelDoc = 'level';
  static const String lastSeenDoc = 'last_seen';
  static const String user1Doc = 'user1';
  static const String user2Doc = 'user2';
  static const String username1Doc = 'username1';
  static const String username2Doc = 'username2';
  //PICTURES
  static const String urlDoc = 'fileUrl';
  static const String hostId = 'hostId';
  static const String pictureTakerDoc = 'pictureTaker';
  static const String timestampDoc = 'timestamp';
  static const String metadataDoc = 'metadata';
  static const String publicDoc = 'public';
  static const String captionDoc = 'caption';
  static const String allowedUsersDoc = 'allowed';
  static const String sessionUsersDoc = 'sessionUsers';
  static const String likesDoc = 'likes';
  static const String firstLikesDoc = 'firstLikes';
  static const String archived = 'archived';
  //STORAGE
  static const String profilePictureStorage = 'profile_pictures';
  static const String sessionPictureStorage = 'session_pictures';
  static const String tempPictureStorage = 'temp';
  static const String postedPictureStorage = 'posted';
  // SOCIAL LINK
  static const double pictureExpValue = 0.2;
  static const double friendshipPowerValue = 1;
  static const int baseLevel = 1;
  static const double baseProgress = 0;
  //COLLECTIONS
  static final CollectionReference friendshipsCollection =
      _firestore.collection('friendships');
  static final CollectionReference usersCollection =
      _firestore.collection('users');
  // SUB COLLECTIONS
  static const String pictureSubCollection = 'pictures';
  // HOME PAGE SIZES
  static const double homeButtonSize = 20;
  static const double homeButtonAddSize = 25;
  static const double homeHorizontalPaddingMultiplier = 0.033;
  static const double homeButtonPadding = 60;
  static const double homeButtonBottomPaddingMultiplier = 0.09;
  //PICTURE SIZES
  static const double pictureDialogWidthMultiplier = 350 / 448;
  // 350*x = 250
  // static const double pictureDialogWidth = 350;
  static const double pictureDialogHeightMultiplier = 0.4;
  // static const double pictureDialogHeight = 400;
  static const double pictureDialogAvatarSize = 30;
  //PICTURE STATES
  static const String pictureState = 'picture';
  static const String cancelledState = 'cancelled';
  static const String pictureMarker = 'pic:';
  static const String publishingState = 'publishing';
  // SHARED PREFERENCES
  static const String darkThemeValue = 'dark';
  static const String lightThemeValue = 'light';
  static const String autoThemeValue = 'auto';
  static const String themeKey = 'theme';
  static const String showHostTutorialKey = 'showHostTutorial';
  static const String showSessionHostTutorialKey = 'showSessionHostTutorial';
  static const String showSessionJoinerTutorialKey =
      'showSessionJoinerTutorial';
  // MOBILE ADS
  static const String androidTestAdUnit =
      'ca-app-pub-3940256099942544/1033173712';
  static const String androidTestNativeAdUnit =
      'ca-app-pub-3940256099942544/2247696110';
  static const String iosTestAdUnit = 'ca-app-pub-3940256099942544/4411468910';
  static const String iosTestNativeAdUnit =
      'ca-app-pub-3940256099942544/3986624511';
  static const String postAdTile = 'postTile';
  // ERRORS
  static const String unknownError = 'unknown-error';
  static const String emailAlreadyInUse = 'email-already-in-use';
  static const String weakPassword = 'weak-password';
  static const String invalidEmail = 'invalid-email';
  static const String usernameError = 'username-already-in-use';
  // ASSETS
  static const String termsAddress = 'assets/policies/terms_and_conditions.md';
  static const String privacyAddress = 'assets/policies/privacy_policy.md';
  static const String defaultPictureAddress =
      'assets/images/account_circle.png';

  // SEPARATORS
  static const String dataSeparator = '_';
  // ADDRESSES
  static const String homepageAddress = '/${MyRouter.homepage}';
  static const String profileAddress = '/${MyRouter.profile}';
  static const String loginAddress = '/${MyRouter.login}';
  static const String signupAddress = '/${MyRouter.signup}';
  static const String forgotAddress = '/${MyRouter.forgot}';
  static const String pictureAddress = '/${MyRouter.picture}';
  static const String sessionAddress = '/${MyRouter.session}';
  static const String mutualAddress = '/${MyRouter.mutual}';
  static const String friendListAddress = '/${MyRouter.friendList}';
  static const String settingsAddress = '/${MyRouter.settings}';
}
