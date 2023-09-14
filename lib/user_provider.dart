import 'package:demo_app/services/chat/users_service.dart';
import 'package:flutter/material.dart';

import 'package:demo_app/model/user.dart'
    as model; // Import your User model here

class UserProvider extends ChangeNotifier {
  model.UserApp? _user;
  final UserServices _userDataFetch = UserServices();
  model.UserApp? get user => _user;

  Future<void> fetchUserData() async {
    model.UserApp user = await _userDataFetch.getUserDetails();

    _user = user;

    notifyListeners();
  }
}
