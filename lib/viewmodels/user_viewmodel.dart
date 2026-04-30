import 'package:flutter/widgets.dart';
import 'package:postgram/models/user_model.dart';
import 'package:postgram/services/auth_service.dart';

class UserViewModel with ChangeNotifier {
  UserModel? _user;
  final AuthService _authService = AuthService();

  UserModel get getUser => _user!;

  Future<void> refreshUser() async {
    UserModel user = await _authService.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
