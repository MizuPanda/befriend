import 'dart:math';

import '../models/bubble.dart';
import '../models/friendship.dart';

class BubbleSample {
  static Bubble connectedUser = Bubble(
    username: '01juniel',
    name: 'Juniel Djossou',
    friendships: _FriendshipSample.juniel,
  );
  static Bubble radu = Bubble(
    username: 'radu.sc_',
    name: 'Radu',
    friendships: _FriendshipSample.radu,
  );
  static Bubble ramy = Bubble(
    username: 'el_ramy0',
    name: 'Ramy',
    friendships: _FriendshipSample.ramy,
  );
  static Bubble yanis = Bubble(
    username: 'sinay_1206',
    name: 'Yanis',
    friendships: _FriendshipSample.yanis,
  );
  static Bubble mayas = Bubble(
    username: 'mayasdj_dz',
    name: 'Mayas Djellal',
    friendships: _FriendshipSample.mayas,
  );

  static initialize() {
    _FriendshipSample.initialize();

    connectedUser.friendships = _FriendshipSample.juniel;
    radu.friendships = _FriendshipSample.radu;
    ramy.friendships = _FriendshipSample.ramy;
    yanis.friendships = _FriendshipSample.yanis;
    mayas.friendships = _FriendshipSample.mayas;

    connectedUser.initializeLevel();
    radu.initializeLevel();
    ramy.initializeLevel();
    yanis.initializeLevel();
    mayas.initializeLevel();
  }
}

class _FriendshipSample {
  static final Random _random = Random();

  static List<Friendship> juniel = [
    Friendship(
      friendBubble: BubbleSample.radu,
      level: 4,
      progress: 20,
      newPics: 0,
    ),
    Friendship(
      friendBubble: BubbleSample.ramy,
      level: 4,
      progress: 80,
      newPics: 1,
    ),
    Friendship(
      friendBubble: BubbleSample.yanis,
      level: 3,
      progress: 50,
      newPics: 4,
    ),
    Friendship(
      friendBubble: BubbleSample.mayas,
      level: 1,
      progress: 90,
      newPics: 0,
    ),
  ];

  static List<Friendship> emptyList = [];

  static List<Friendship> radu = emptyList;
  static List<Friendship> ramy = emptyList;
  static List<Friendship> yanis = emptyList;
  static List<Friendship> mayas = emptyList;

  static initialize() {
    radu = [
      Friendship(
        friendBubble: BubbleSample.connectedUser,
        level: 4,
        progress: 20,
        newPics: _randPics(),
      ),
      _randFriendship(BubbleSample.ramy),
      _randFriendship(BubbleSample.yanis),
      _randFriendship(BubbleSample.mayas)
    ];

    ramy = [
      Friendship(
        friendBubble: BubbleSample.connectedUser,
        level: 4,
        progress: 80,
        newPics: _randPics(),
      ),
      _randFriendship(BubbleSample.radu),
      _randFriendship(BubbleSample.yanis),
      _randFriendship(BubbleSample.mayas)
    ];

    yanis = [
      Friendship(
        friendBubble: BubbleSample.connectedUser,
        level: 3,
        progress: 50,
        newPics: _randPics(),
      ),
      _randFriendship(BubbleSample.radu),
      _randFriendship(BubbleSample.ramy),
      _randFriendship(BubbleSample.mayas)
    ];

    mayas = [
      Friendship(
        friendBubble: BubbleSample.connectedUser,
        level: 1,
        progress: 90,
        newPics: _randPics(),
      ),
      _randFriendship(BubbleSample.radu),
      _randFriendship(BubbleSample.ramy),
      _randFriendship(BubbleSample.yanis)
    ];
  }

  static _randFriendship(Bubble friendBubble) {
    return Friendship(
      friendBubble: friendBubble,
      level: _randLevel(),
      progress: _randProgress(),
      newPics: _randPics(),
    );
  }

  static int _randLevel() {
    return _random.nextInt(4);
  }

  static double _randProgress() {
    return _random.nextDouble() * 100;
  }

  static int _randPics() {
    return _random.nextInt(9);
  }
}
