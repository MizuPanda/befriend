import 'package:befriend/models/data/picture_query.dart';
import 'package:befriend/models/data/user_manager.dart';

import '../models/authentication/authentication.dart';
import '../models/data/data_manager.dart';
import '../models/data/data_query.dart';

class Models {
  static DataQuery dataQuery = DataQuery.static();
  static AuthenticationManager authenticationManager = AuthenticationManager.static();
  static DataManager dataManager = DataManager.static();
  static PictureQuery pictureQuery = PictureQuery.static();
  static UserManager userManager = UserManager.static();
}