import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserService {
  //static String _baseUrl = 'http://34.16.154.218:8000';
  static String _baseUrl = 'http://127.0.0.1:8000';

  static Future<bool> registerUser(UserMod user) async {
    var url = Uri.parse('$_baseUrl/api/users/');
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': user.name,
          'email': user.email,
          'password': user.password,
          'shippingAddress': user.shippingAddress,
          'cart': user.cart ?? [],
          'reviews': user.reviews ?? [],
          'questions': user.questions ?? [],
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to register user. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception caught: $e');
      return false;
    }
  }


  static Future<UserMod?> getUser(String email) async {
    var url = Uri.parse('$_baseUrl/api/users/?email=$email');
    try {
      var response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var users = json.decode(response.body);
        if (users is List<dynamic>) {
          for (var user in users) {
            return UserMod.fromJson(user);
          }
        }
      }
      return null;
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Failed to fetch user');
    }
  }
  static Future<bool> updateUser(UserMod user) async {
    var url = Uri.parse('$_baseUrl/api/users/${user.id}/');

    try {
      var cartUpdatePayload = json.encode({
        'cart': user.cart,
      });

      var response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: cartUpdatePayload,
      );
      if (response.statusCode == 200 || response.statusCode == 204) { 
        return true;
      } else {
        print('Failed to update user cart. Status code: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('Error updating user cart: $error');
      return false; 
    }
  }

  static Future<UserMod?> getUserbyId(int id) async {
    var url = Uri.parse('$_baseUrl/api/users/?id=$id');
    try {
      var response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var users = json.decode(response.body);
        if (users is List<dynamic>) {
          for (var user in users) {
            return UserMod.fromJson(user);
          }
        }
      }
      return null;
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Failed to fetch user');
    }
  }

  static Future<UserMod?> authenticateUser(String email, String password) async {
    var url = Uri.parse('$_baseUrl/api/users/?email=$email&password=$password');
    try {
      var response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var users = json.decode(response.body);
        if (users is List<dynamic>) {
          for (var user in users) {
              return UserMod.fromJson(user);
            }
          }
        }
      return null;
    } catch (e) {
      print('Exception caught: $e');
      return null;
    }
  }
}
