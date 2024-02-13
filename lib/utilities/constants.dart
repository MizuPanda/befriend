import 'package:befriend/router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Constants {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String appID = 'befriend';
  //USERS
  static const String nameDoc = 'name';
  static const String usernameDoc = 'username';
  static const String avatarDoc = 'avatar';
  static const String counterDoc = 'counter';
  static const String friendsDoc = 'friends';
  static const String powerDoc = 'power';
  static const String hostingDoc = 'hosting';
  static const String sliderDoc = 'sliderValue';
  static const String hostingFriendships = 'hostingFriendships';
  static const String pictureSubCollection = 'pictures';
  //FRIENDSHIPS
  static const String progressDoc = 'progress';
  static const String levelDoc = 'level';
  static const String lastSeenDoc = 'last_seen';
  static const String userDoc = 'user';
  //PICTURES
  static const String urlDoc = 'fileUrl';
  static const String pictureTakerDoc = 'pictureTaker';
  static const String timestampDoc = 'timestamp';
  static const String metadataDoc = 'metadata';
  static const String publicDoc = 'public';
  static const String captionDoc = 'caption';
  static const String allowedUsersDoc = 'allowed';
  static const String usersHavingSeenDoc = 'usersThatHaveSeen';
  //STORAGE
  static const String profilePictureStorage = 'profile_pictures';
  static const String sessionPictureStorage = 'session_pictures';
  static const String tempPictureStorage = 'temp';
  static const String postedPictureStorage = 'posted';
  // SOCIAL LINK
  static const double pictureExpValue = 0.1;
  static const int baseLevel = 1;
  static const double baseProgress = 1;
  //COLLECTION
  static final CollectionReference friendshipsCollection =
      _firestore.collection('friendships');
  static final CollectionReference usersCollection =
      _firestore.collection('users');
  // HOME PAGE SIZES
  static const double viewerSize = 5000;
  static const double homeButtonSize = 20;
  static const double homeButtonAddSize = 25;
  static const double homeHorizontalPadding = 15;
  static const double homeButtonPadding = 60;
  //PICTURE SIZES
  static const double pictureDialogWidth = 350;
  static const double pictureDialogHeight = 450;
  static const double pictureDialogAvatarSize = 30;
  //PICTURE STATES
  static const String pictureState = 'picture';
  static const String cancelledState = 'cancelled';
  static const String pictureMarker = 'pic:';
  static const String publishingState = 'publishing';
  // ADDRESSES
  static const String homepageAddress = '/${MyRouter.homepage}';
  static const String profileAddress = '/${MyRouter.profile}';
  static const String loginAddress = '/${MyRouter.login}';
  static const String signupAddress = '/${MyRouter.signup}';
  static const String forgotAddress = '/${MyRouter.forgot}';
  static const String pictureAddress = '/${MyRouter.picture}';
  static const String sessionAddress = '/${MyRouter.session}';
  static const String mutualAddress = '/${MyRouter.mutual}';
}
