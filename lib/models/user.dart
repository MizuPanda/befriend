import '../utilities/samples.dart';
import 'home.dart';

class UserManager {
  static Home userHome() {
    return Home(user: BubbleSample.connectedUser, connectedHome: true);
  }
}
