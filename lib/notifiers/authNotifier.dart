import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:canteen_food_ordering_app/models/user.dart';
import 'package:flutter/foundation.dart';

class AuthNotifier extends ChangeNotifier {
  // Make _user nullable by adding '?'
  firebase_auth.User? _user;

  firebase_auth.User? get user => _user;

  // Update the setUser method to accept firebase_auth.User? (nullable user)
  void setUser(firebase_auth.User? user) {
    _user = user;
    notifyListeners();
  }

  late User _userDetails;

  User get userDetails => _userDetails;

  void setUserDetails(User user) {
    _userDetails = user;
    notifyListeners();
  }
}
