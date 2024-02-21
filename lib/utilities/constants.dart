import 'package:befriend/router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Constants {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String appID = 'befriend';
  //USERS
  static const String nameDoc = 'name';
  static const String usernameDoc = 'username';
  static const String notificationToken = 'notificationToken';
  static const String avatarDoc = 'avatar';
  static const String counterDoc = 'counter';
  static const String friendsDoc = 'friends';
  static const String powerDoc = 'power';
  static const String hostingDoc = 'hosting';
  static const String sliderDoc = 'sliderValue';
  static const String hostingFriendshipsDoc = 'hostingFriendships';
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
  static const String pictureTakerDoc = 'pictureTaker';
  static const String timestampDoc = 'timestamp';
  static const String metadataDoc = 'metadata';
  static const String publicDoc = 'public';
  static const String captionDoc = 'caption';
  static const String allowedUsersDoc = 'allowed';
  static const String sessionUsersDoc = 'sessionUsers';
  static const String likesDoc = 'likes';
  static const String firstLikesDoc = 'firstLikes';
  //STORAGE
  static const String profilePictureStorage = 'profile_pictures';
  static const String sessionPictureStorage = 'session_pictures';
  static const String tempPictureStorage = 'temp';
  static const String postedPictureStorage = 'posted';
  // SOCIAL LINK
  static const double pictureExpValue = 0.1;
  static const int baseLevel = 1;
  static const double baseProgress = 1;
  //COLLECTIONS
  static final CollectionReference friendshipsCollection =
      _firestore.collection('friendships');
  static final CollectionReference usersCollection =
      _firestore.collection('users');
  // SUB COLLECTIONS
  static const String pictureSubCollection = 'pictures';
  // HOME PAGE SIZES
  static const double viewerSize = 5000;
  static const double homeButtonSize = 20;
  static const double homeButtonAddSize = 25;
  static const double homeHorizontalPadding = 15;
  static const double homeButtonPadding = 60;
  //PICTURE SIZES
  static const double pictureDialogWidth = 350;
  static const double pictureDialogHeight = 400;
  static const double pictureDialogAvatarSize = 30;
  //PICTURE STATES
  static const String pictureState = 'picture';
  static const String cancelledState = 'cancelled';
  static const String pictureMarker = 'pic:';
  static const String publishingState = 'publishing';
  // MOBILE ADS
  static const String androidTestAdUnit =
      'ca-app-pub-3940256099942544/1033173712';
  static const String androidTestNativeAdUnit =
      'ca-app-pub-3940256099942544/2247696110';
  static const String iosTestAdUnit = 'ca-app-pub-3940256099942544/4411468910';
  static const String iosTestNativeAdUnit =
      'ca-app-pub-3940256099942544/3986624511';
  static const String postAdTile = 'postTile';
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
}
