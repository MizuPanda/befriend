import 'bubble.dart';

class Host {
  Bubble host;
  List<Bubble> joiners;
  Bubble user;

  Host({
    required this.host,
    required this.joiners,
    required this.user
  });

  bool main() {
    return host == user;
  }
}