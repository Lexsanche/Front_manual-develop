import 'package:flutter/material.dart';
import 'package:front_manual/services/user_service.dart';
import '../models/user.dart';

class UserProviderService with ChangeNotifier {
  UserMod? _user;

  UserMod? get user => _user;

  void setUser(UserMod user) {
    _user = user;
    notifyListeners();
  }

  Future<void> fetchUser(int id) async {
    try {
      UserMod? gottenUser = await UserService.getUserbyId(id);
      if (gottenUser != null) {
        setUser(gottenUser);
      }
    } catch (e) {
      print(e.toString());
    }
  }
  Future<void> updateCart(List<Map<String, dynamic>> newCart) async {
    if (user == null) return;

    user!.cart = newCart; 
    bool success = await UserService.updateUser(user!); 

    if (success) {
      notifyListeners();
    } else {
      print("Failed to update the cart in the backend.");
    }
  }
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}